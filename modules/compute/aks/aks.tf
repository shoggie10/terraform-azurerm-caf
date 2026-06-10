## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
### Naming convention

resource "azurecaf_name" "aks" {
  name          = var.settings.name
  resource_type = "azurerm_kubernetes_cluster"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurecaf_name" "default_node_pool" {
  name          = var.settings.default_node_pool.name
  resource_type = "aks_node_pool_linux"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

# locals {
#   rg_node_name = lookup(var.settings, "node_resource_group", "${var.resource_group.name}-nodes")
# }

resource "azurecaf_name" "rg_node" {
  name          = var.settings.node_resource_group_name
  resource_type = "azurerm_resource_group"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}
=====================================||========================================================================
IDP Pilot — Living Technical Documentation
Maintained by: Sogo Alonge (sogo.alonge@groupo.com)
Last updated: May 28, 2026
Branch: feature/idp-pipeline-v2
Status: GO/NO-GO DECIDED (2026-05-27) — No-Go on further pipeline refinement. Current state accepted as good enough for business use and VXXXXXs integration. Focus is now entirely on integration readiness and handoff.

This is a living document covering the full project history from April 2026 to present. Accuracy, known issues, and next steps should be refreshed after each benchmark run or significant milestone. Sections marked [UPDATE] need attention after each run.

Table of Contents
•	1. Project Overview
•	2. System Architecture
•	3. Validation Rules
•	4. Accuracy History — Full Progression
•	5. All Fixes Applied (April – May 2026)
•	6. Test Data Corrections
•	7. NR Analysis — Why Claims Route to Needs Review
•	8. Edge Cases & Known Limitations
•	9. Carrier Configuration & Data
•	10. Database Schema
•	11. Cost & Performance
•	12. Business Decisions
•	13. VXXXXXs Integration
•	14. Improvement Roadmap — Phases 0–4
•	15. Known Issues & Monitoring
•	16. How to Run
•	17. Handoff Readiness

 
1. Project Overview
The Azure IDP (Intelligent Document Processing) pilot is an AI pipeline that automatically validates carrier bills submitted as part of ETF (Early Termination Fee) switch claims. When a customer switches to AT&T, they may be eligible to have their smartphone installment balance paid off. This pipeline determines whether the submitted carrier bill meets the eligibility criteria — replacing a fully manual human review process.
Business Context
Item	Detail
Program	AT&T Switcher Offer — reimburses outstanding device balances for qualifying switchers
Validation trigger	Customer submits carrier bill as proof of installment balance
Current state	AI pipeline with human-in-the-loop (Needs Review) for ambiguous cases
Pilot goal	Reach >88% all-in accuracy on T-Mobile and Verizon (Josh's accepted floor)
Handoff target	VXXXXXs POC → Production deployment
Primary stakeholders	Cory Shounick (project owner), Josh VP (accuracy floor), Ryan Nelson (business rules), VXXXXXs
Project start	April 2026
Current phase	B2 fresh eval complete; VXXXXXs integration alignment in progress

Decision Definitions
Decision	Meaning	Rules Matched	Counts As
Passed	All 6 rules match human validation	6/6	AutoCorrect
Partial_High	5 of 6 rules match — off by 1	5/6	AutoCorrect
Needs_Review (NR)	Cannot extract required data — human review	N/A	NR (counts against all-in)
Partial_Low	4 or fewer rules correct	≤4/6	AutoWrong
Extraction_Error	Document processing failed entirely	N/A	AutoWrong

All-in accuracy = AutoCorrect / Total.  Decidable accuracy = AutoCorrect / (Total − NR).  Josh's accepted floor: ~88% all-in. NR claims count against all-in — this is the production-representative metric.
Accuracy Summary: Current State [UPDATE after each run]
Carrier	Eval	n	All-In Acc	Decidable Acc	NR Rate	vs 88% Floor	Prompt
T-Mobile	B1 curated	98	88.8%	100.0%	11.2%	Above floor ✓	v1.3.3
Verizon	B1 curated	96	83.3%	100.0%	13.5%	Below floor	v1.3.1
T-Mobile	B2 fresh	100	80.0%	94.1%	15.0%	Below floor*	v1.3.3
Verizon	B2 fresh	100	72.0%	92.3%	22.0%	Below floor*	v1.3.1
Spectrum	run_080	47	27.7%	100.0%	72.3%	On hold	v1.2.0
Comcast	run_079	49	18.4%	90.0%	79.6%	On hold	v1.2.0

*B2 fresh eval uses previously unseen claims — production-representative. B1/B2 gap (~8–11pp) is expected: prompts were tuned against B1 claims. B2 is confirmed T-Mobile good enough for now; prompt refinement on hold. B2 gap to be discussed in Go/No-Go with Cory.
 
2. System Architecture
Current Pipeline Flow
Step	Description
1. Claim Load	Query Data_Historical_Archive (Azure SQL) for claims; NOT EXISTS filter skips already-evaluated claims in fresh batch mode
2. Blob Fetch	Download bill documents (PDF/JPEG/PNG) from Azure Blob Storage. Primary container: etfswitcher. Fallback: attrewardcenter (Fix N)
3. Pre-processing	JPEG: EXIF rotation baked in + resize to max 2048px (Fix O). PDF: Activity log sections stripped from ADI markdown (Fix M)
4. OCR / Extraction	PDF → Azure Document Intelligence prebuilt-layout → markdown → GPT-4.1. JPEG → GPT-4.1 vision directly. CTN hint injected into prompt (Fix P)
5. Pydantic	BillExtraction + DeviceExtraction validators: normalize phone, balance, progress, date. Strict JSON schema enforced at OpenAI API level
6. Account Buyouts	Regex scan of ADI HTML markdown for account-level Device Payment Buyout Charges (Verizon — Fix K). Passed to rules engine as account_level_buyouts[]
7. Aggregation	Multi-document claims: device records merged by CTN; most-complete entry retained. account_level_buyouts preserved through merge
8. Markdown Scan	Pipeline scans raw DI markdown for claim CTN; checks 80-char window for ineligible device keywords
9. Rules Engine	6 business rules evaluated; NR triggered on 5 conditions; AutoCorrect/AutoWrong/NR decision made
10. Results Write	Per-claim commit to AI_Evaluation_Results immediately after each claim (Fix A) — prevents data loss on process death

Planned Architecture (Do Not Build Around Current DI Path)
The current Doc Intelligence → markdown → GPT chain will be replaced with pure OpenAI multimodal (vision) — one model call handles both OCR and extraction. This eliminates the lossy markdown conversion step. VXXXXXs' architecture already anticipates this: their OCR Extraction API wraps ADI and their AI Extraction API wraps OpenAI as separate microservices, making the migration a swap of the OCR component. Do not invest new effort in DI-specific code paths.
VXXXXXs Target Architecture (Azure Functions Microservices)
Component	Description	XXXXX X Asset Used
Claim Ingestion API	App Service — receives Input JSON from Connections system	Connections system (existing)
Claim Processing Scheduler	Timer trigger — batches claims (10 at a time) to Service Bus	Mirrors batch.py logic
Durable Function	Orchestrates per-claim processing; updates status in COMOS DB	Replaces batch.py
OCR Extraction API	HTTP Function wrapping Azure Document Intelligence	Replaces DI path in openai_layout.py
AI Extraction API	HTTP Function wrapping OpenAI GPT-4.1	Prompt templates + extraction schema
JSON Schema Validator	HTTP Function validating extraction output completeness	Mirrors Pydantic validation
Rules Engine API	Queue-triggered Function applying 6 validation rules	Extraction rules + edge case logic (this doc)
Update Connections API	HTTP Function posting final decision back to Connections	Mirrors current result write

Primary handoff assets to VXXXXXs: (1) GPT-4.1 prompt templates, (2) extraction rules & edge case logic (see Section 8 and IDP_Handoff_Guide_VXXXXXs_2026-05-28.docx)
Azure Services Used
Service	Purpose	Resource / Config
Azure SQL (serverless)	Claims data, AI results, config tables	AZURE_SQL_SERVER / AZURE_SQL_DATABASE
Azure Blob Storage	Bill document storage (PDF/JPEG/PNG)	AZURE_BLOB_ACCOUNT_NAME — containers: etfswitcher, attrewardcenter
Azure Document Intelligence	OCR — prebuilt-layout model (current; to be replaced)	AZURE_DI_ENDPOINT
Azure OpenAI gpt-4.1	Primary extraction model	AZURE_OPENAI_GPT_ENDPOINT (claim-processor-v1)
Azure OpenAI gpt-4o	Fallback for large PDFs	AZURE_OPENAI_ENDPOINT (openaigroupodev01receiptvalidation)
DefaultAzureCredential	Auth for all Azure resources	AZURE_CLIENT_ID (managed identity)

Key Files
File	Purpose
production/pipeline/batch.py	Batch orchestrator; per-claim commits; markdown scanner; NOT EXISTS SQL filter
production/rules/validation_rules.py	6 rules; NR routing; account-level buyout logic; Fix C auto-pass
production/rules/validation_helpers.py	parse_installment_progress(); parse_balance(); normalize_phone_number()
production/models/openai_layout.py	GPT extraction; Pydantic validation; Fix K regex; Fix M strip; Fix O EXIF/resize
production/pipeline/aggregation.py	Completeness-based device merging; account_level_buyouts preservation
production/services/database.py	load_claims() with NOT EXISTS filter; append_evaluation_results()
production/services/blob_storage.py	attrewardcenter fallback (Fix N); SAS URL generation; EXIF + resize (Fix O)
production/config/loader.py	get_extraction_prompt() with CTN hint injection (Fix P); carrier prompt routing
production/models/device_classifier.py	classify_device(); Provisional Device ID / 5G Core handling (Fix G)

 
3. Validation Rules
Rule Key	What It Checks	Pass Condition	Fail Condition	NR Condition
Val_CopyOfBill	Document is a genuine carrier bill	Any bill data extracted	Store receipt, transfer letter, non-bill doc	Never NR — always Pass or Fail
Val_CTNMatch	Bill phone number matches claim CTN	Extracted phone == BillPhone (10-digit match)	CTN found near confirmed ineligible device	CTN not found in any extracted device
Val_InstallmentPlanPayoff	Device has active installment balance	Balance > $0 OR Final charge on cancelled line	Balance = $0 AND no cancelled-line language	Installment details not visible on document
Val_FourMonthsService	Customer has ≥ 4 installment payments made	Payment number ≥ 4 of total	Payment 1, 2, or 3 of total	Payment number not extractable
Val_BillDateValid	Bill is within 120 days of submission	0 ≤ (submission − bill_date) ≤ 120 days	Bill date > 120 days old OR wrong year	Bill date cannot be parsed
Val_NotTabletWearable	Device is a smartphone	Device classified as Phone	Device is Tablet, Wearable, Hotspot, HomeInternet, Accessory	Device unknown AND CTN unmatched

Business Rulings on Validation Rules
Rule	Scenario	Decision	Authority	Date
Val_FourMonthsService	"Payment 2 of 24"	Incomplete — EIP count on current device, not service tenure	Ryan Nelson	May 6, 2026
Val_FourMonthsService	"Final charge (line cancelled)"	Complete — remaining balance proves active EIP, treat as 4+ months	Ryan Nelson	May 7, 2026
Val_InstallmentPlanPayoff	Account-level Device Payment Buyout Charge (VZ)	Valid installment evidence even without per-CTN association	Ryan Nelson	May 14, 2026
Val_FourMonthsService	Not-in-good-standing language	Past-due flag only — remaining balance does NOT disqualify	Ryan Nelson	May 14, 2026
Val_FourMonthsService	"Payment 3 of 24" (1215265/1217831)	Incomplete — same principle as Payment 2 of 24	Ryan Nelson (implied)	May 7, 2026

NR Routing — 5 Trigger Conditions
#	Trigger	Root Cause	Fix Available
1	Bill date not parseable	Degraded doc; unusual date label	Prompt tuning; pdfplumber fallback (Phase 3A)
2	CTN not found in extracted devices	Summary/cover page; blobs missing; image quality	Multi-page routing (Phase 3B); Fix N/O/P applied
3	CTN matched, no installment detail	Summary page — account total only	Account-level buyout (Fix K for VZ); Phase 3B
4	Installment progress < 4 months AND no balance	Partial extraction; borderline document	Prompt fixes (Phase 2)
5	Device type unknown AND CTN not matched	Device description not in classifier patterns	Expand classifier keywords; Phase 2

Unknown devices route to NR — NOT auto-fail. Only confirmed ineligible classes (Tablet, Wearable, Hotspot, HomeInternet) auto-fail.
Device Classification
Classification	Val_NotTabletWearable	Examples	Behavior
Phone	Pass	iPhone, Samsung Galaxy S/Z, Google Pixel, OnePlus, Moto G/Edge	Eligible — claim proceeds
Tablet	Fail	iPad, Samsung Galaxy Tab, Surface	Auto-fail — claim denied
Wearable	Fail	Apple Watch, Galaxy Watch, Galaxy Fit, Gear	Auto-fail — claim denied
Hotspot	Fail	MiFi, Jetpack, Mobile Hotspot	Auto-fail — claim denied
HomeInternet	Fail	5G Home Internet gateway, Inseego gateway	Auto-fail — claim denied
Accessory	Fail	AirPods, earbuds, USB-C adapter	Auto-fail — claim denied
Unknown	NR	Unrecognized device string	Routes to NR — human review

 
4. Accuracy History — Full Progression [UPDATE]
4.1 Foundation Runs (April 2026)
Run	Carrier	n	AutoCorrect	NR	AutoWrong	Decidable	All-In	Key Event
run_060	TM+VZ	59	46	0	13	78.0%	78.0%	Baseline — gpt-5.1, no NR routing (excluded from progression)
run_061	TM+VZ	60	42	16	2	95.5%	70.0%	First full pipeline: Pydantic + NR routing + carrier prompts
run_063	TM+VZ	60	43	16	1	97.7%	71.7%	+NR fix for partial extraction (claim 671502)
run_064	TM+VZ	100	70	29	1	98.6%	70.0%	Expanded to 100 claims; 98.6% decidable

4.2 Carrier-Dedicated Baselines (May 1–4, 2026)
Run	Carrier	n	AutoCorrect	NR	AutoWrong	Decidable	All-In	Key Event
run_074	T-Mobile	49	33	15	1	97.1%	67.3%	T-Mobile v1.2.0 dedicated baseline
run_075	Verizon	48	35	9	4	89.7%	72.9%	Verizon v1.1.0 baseline; 4 Extraction_Error
run_076	Verizon	48	36	12	0	100.0%	75.0%	Fix #1+#4; Extraction_Error → NR; 0 AutoWrong
run_077	T-Mobile	49	37	11	1	97.4%	75.5%	Fix #3; NR 15→11
run_079	Comcast	49	9	39	1	90.0%	18.4%	Comcast v1.2.0 baseline
run_080	Spectrum	47	13	34	0	100.0%	27.7%	After 2 Spectrum test data corrections
run_081	T-Mobile	48	36	11	1	97.3%	75.0%	v1.3.1; Fix #6; NR not converted
run_082	Verizon	46	33	13	0	100.0%	71.7%	v1.3.0 Fix #7+#8; buyout claims still NR

4.3 OI Fix Validation & Clean Baselines (May 5–7, 2026)
Run	Carrier	n	AutoCorrect	NR	AutoWrong	Decidable	All-In	Key Event
run_083	TM+VZ	10	4	0	6	40.0%	40.0%	OI validation — 10 hardest claims (low acc expected)
run_089	T-Mobile	48	37	8	3	92.5%	77.1%	Re-run; 2 residual bugs found
run_090	Verizon	46	34	8	4	89.5%	73.9%	Re-run; 2 pipeline bugs exposed
run_091	Verizon	46	34	12	0	100.0%	73.9%	✅ CLEAN — 0 AutoWrong; all OI fixes applied
run_092	T-Mobile	48	40	8	0	100.0%	83.3%	✅ CLEAN — 0 AutoWrong; all OI fixes applied

4.4 Verizon Accuracy Improvement Fixes (May 7–20, 2026)
Run	Carrier	n	AutoCorrect	NR	AutoWrong	Decidable	All-In	Key Event
run_093	T-Mobile	48	43	5	0	100.0%	89.6%	Fix F re-run; TM +6.3pp
run_109	Verizon	46	36	10	0	100.0%	78.3%	Fix J (vision 429 retry + throttle); +4.3pp VZ
run_117	Verizon	46	41	5	0	100.0%	89.1%	Fix K v5 (buyout regex HTML fix); +4.3pp VZ
run_123	Verizon	46	43	3	0	100.0%	93.5%	Fix M (strip activity sections); +4.4pp VZ ✅
run_128	T-Mobile	48	42	5	1	97.7%	87.5%	Fix N (attrewardcenter fallback); +8.3pp TM
run_130	T-Mobile	48	41	5	2	95.3%	85.4%	Fix O v2 (EXIF + resize 2048px)
run_131	T-Mobile	48	44	1	3	93.6%	91.7%	Fix P (CTN hint); best TM run to date (volatile)
run_132	T-Mobile	48	43	2	3	93.5%	89.6%	Fix P stability check; 1193583 volatile

4.5 Expanded Eval & B1/B2 Fresh Eval (May 20–21, 2026)
Run	Carrier	n	AutoCorrect	NR	AutoWrong	Decidable	All-In	Key Event
run_133	T-Mobile	73	65	3	5	92.9%	89.0%	TM expanded +25 claims; above floor ✓
run_134	Verizon	71	58	12	1	98.3%	81.7%	VZ expanded +25; NR spike on older claims
run_137	Verizon	71	62	8	1	98.4%	87.3%	Fix Q (VZ JPEG buyout); +5.6pp VZ
run_139	T-Mobile	25	22	3	0	100.0%	88.0%	+25 new TM claims; combined B1: 88.8% (n=98)
run_140	Verizon	25	18	4	3	86.0%	72.0%	+25 new VZ; 5G Core misclassifications found
run_141	T-Mobile	50	40	7	3	93.0%	80.0%	B2 fresh eval batch 1 (50 unseen claims)
run_142	T-Mobile	50	40	8	2	95.2%	80.0%	B2 batch 2; combined B2: 80.0% (n=100) ⚠
run_143	Verizon	50	38	8	4	90.5%	76.0%	B2 fresh eval batch 1 (50 unseen claims)
run_144	Verizon	50	34	14	2	94.4%	68.0%	B2 batch 2; combined B2: 72.0% (n=100) ⚠

B2 gap vs B1: TM -8.8pp (88.8%→80.0%), VZ -11.3pp (83.3%→72.0%). Gap is expected — prompts were tuned against B1 claims. B2 NR rate higher (TM 15%, VZ 22%) than B1 (TM 6.1%, VZ 12.5%) due to unseen claim formats. Cory confirmed TM is good enough; prompt refinement on hold.
4.6 Key Milestones Timeline
Date	Milestone
Apr 21, 2026	run_061 — first full pipeline; NR routing live; 95.5% decidable
Apr 27, 2026	run_064 — 100 claims; 98.6% decidable; all baseline failures resolved
May 1, 2026	Dedicated T-Mobile (run_074) and Verizon (run_075) baselines established
May 4, 2026	Fixes #1–#8 applied; all 4 carriers evaluated; VZ 100% decidable (run_076)
May 6, 2026	OI fixes A–E applied; Ryan Nelson decisions received
May 7, 2026	run_092 TM: 100% decidable / 83.3% all-in ✅ | run_091 VZ: 100% decidable / 73.9% all-in ✅
May 14, 2026	Ryan Nelson ruling: account-level buyout = valid installment evidence (Fix K)
May 20, 2026	Fix M applied: VZ 89.1%→93.5% (run_123); Josh sets ~88% all-in floor
May 20, 2026	Fix N applied: TM 79.2%→87.5% (run_128)
May 20, 2026	Fix P applied: TM 85.4%→89.6–91.7% (runs 131–132, volatile)
May 20, 2026	B1 curated eval: TM 88.8% (n=98), VZ 83.3% (n=96) — above / near floor
May 21, 2026	VXXXXXs training session delivered by Sogo
May 21, 2026	B2 fresh eval complete: TM 80.0% (n=100), VZ 72.0% (n=100) — below floor
May 27, 2026	Cory back from vacation; alignment meeting — prompt refinement on hold; integration focus
May 28, 2026	Extraction rules & edge cases handoff guide prepared for VXXXXXs (due Fri 05/30)

 
5. All Fixes Applied (April – May 2026)
5.1 Foundation Fixes (April 2026 — run_061 baseline)
Component	What Changed	Impact
NR Routing	5-condition routing layer — NR instead of auto-fail when data missing	78%→95.5% decidable
Pydantic Validation	Field-level contracts: phone, balance, progress, date normalization	Eliminated silent format failures
Structured JSON	response_format: json_schema enforced on every OpenAI extraction call	Eliminated unparseable responses
Multi-Pass Date	Second focused API call when bill_date missing; targets first 3,000 chars	Recovered 2 baseline failures
Device Merging	Completeness-based CTN merge across documents; deduplication	Fixed VZ split-row + multi-doc
TypedDicts	Typed boundaries at every pipeline stage (pipeline/types.py)	Dev-time error prevention
Direct Azure Infra	Live SQL + Blob reads via DefaultAzureCredential	Production-ready pipeline
Prompt v1.1.0+	T-Mobile + Verizon carrier-specific edge cases; EIP, DPA, date labels	Carrier-specific accuracy

5.2 Carrier-Specific Fixes (May 1–4, 2026)
#	Fix	Carrier	File	What Changed	Impact
1	Extraction_Error → NR	All	batch.py	has_error → Needs_Review, not Submitted Incomplete	Eliminated incorrect auto-fails
2	Carrier filter normalization	All	database.py	Strip hyphens/spaces; LOWER() match; T-Mobile=TMobile=t mobile	Fixed --carrier flag matching
3	FourMonths phrasing variants	All 4	Config_Prompts	INSTALLMENT PROGRESS section; all X of Y phrasings; Spanish	Resolved multi-carrier NR claims
4	Store receipt rejection (VZ)	Verizon	Config_Prompts	Explicit rejection of Verizon store receipts	Correct CopyOfBill failures
5	Multi-doc conflict (closed)	T-Mobile	—	1194022 was test data error; AI correct; no prompt change needed	Test data fix only
6	Removed-line HANDSETS lookup	T-Mobile	Config_Prompts v1.3.1	Guidance for Removed lines; Final charge handling	1193593 conversion attempt
7	Buyout format (X-Y)	Verizon	Config_Prompts	Document Payment Buyout Charge (X-Y) format and X-1 interpretation	VZ FourMonths NR reduction
8	5G Core device exclusion	Verizon	Config_Prompts	Explicit exclusion of Provisional Device 5G Core from devices[]	See OI-001 — ambiguous label

5.3 Post-OI Pipeline Fixes (May 5–7, 2026)
Fix	File	What Changed	Run Validated
Fix A — Per-claim DB commits	batch.py	append_evaluation_results() after each claim; prevents data loss on process death	run_092/run_091
Fix B — Timeout NULL-safe coercion	openai_layout.py	int(get_param(...) or 120) — prevents requests.post(timeout=None) infinite hang	run_092/run_091
Fix C — Issue 2b auto-pass	validation_rules.py	Final charge (line cancelled) + non-zero balance → auto-pass FourMonths	run_092
Fix D — Buyout notation (X-Y)	validation_helpers.py	parse_installment_progress() recognizes (X-Y); returns (X, Y) — X payments made	run_092
Fix E — Final charge + balance	validation_helpers.py, validation_rules.py	balance_str passed through; Final charge + balance > 0 → (4,24)	run_092
Neighbor CTN 80-char window	batch.py	_classify_ctn_from_markdown: 500→80-char window; skips if another CTN nearby	run_091
Ineligible class fix	validation_rules.py	Unknown → NR (not auto-fail); only {Tablet, Wearable, Hotspot, HomeInternet} fail	run_091
Fix B regression — REMOVED	batch.py	bill_date_conflict NR trigger removed; caused 10 TM + 5 VZ valid claims → NR	run_089/run_090

5.4 Accuracy Improvement Fixes (May 7–20, 2026)
Fix	File	What Changed	Impact
Fix J — Vision 429 retry	openai_layout.py, services/retry.py	3-sec inter-call throttle + retry 429/503 with 15s/30s/60s delays	Resolved all 429 failures; VZ +4.3pp (run_109)
Fix K v5 — Account buyout regex	openai_layout.py	_BUYOUT_RE regex extracts account-level buyout from ADI HTML markdown	VZ +4.3pp 78.3%→89.1% (run_117)
Fix L — Doc Intel 429 retry	services/retry.py	DI 429 retry with 15/30/60s delays + 3s inter-call throttle	Resilience measure; no direct acc gain
Fix M — Strip activity sections	openai_layout.py	_strip_activity_sections() removes Talk/Data/Message logs; 99K→13K chars	VZ +4.4pp 89.1%→93.5% (run_123) ✅
Fix N — attrewardcenter fallback	blob_storage.py	Retry blob not found in etfswitcher against attrewardcenter container	TM +8.3pp 79.2%→87.5% (run_128) ✅
Fix O — EXIF rotation + resize	blob_storage.py, openai_layout.py	Pillow bakes EXIF rotation; resize to max 2048px; bypasses Zscaler truncation	Fixed sideways JPEGs; proxy truncation (run_130)
Fix P — CTN hint injection	config/loader.py	Appends claim_ctn hint to extraction prompt via get_extraction_prompt()	TM +4.2pp 85.4%→89.6–91.7% (runs 131–132)
Fix Q — VZ JPEG buyout	openai_layout.py	Extended Fix K to JPEG/vision path (was PDF-only)	VZ +5.6pp 81.7%→87.3% (run_137) ✅

 
6. Test Data Corrections
All corrections applied via fix_test_data_errors.py and confirmed by blob inspection or Ryan Nelson ruling.
Claim	Carrier	Rule(s)	Was	Corrected To	Confirmed By	Date
671586	Verizon	3 rules	Incomplete	Complete	Blob inspection — human data entry error	Apr 2026
671463	T-Mobile	Val_FourMonthsService	Complete	Incomplete	Blob inspection	Apr 2026
1194022	T-Mobile	Val_BillDateValid, Val_InstallmentPlanPayoff	Incomplete	Complete	Doc 2 was zoom crop of Doc 1 — same bill	May 1
1192122	Spectrum	All 6 rules	Incomplete	Complete	Spanish-language bill; human couldn't read it	May 4
1188973	Spectrum	Val_FourMonthsService	Complete	Incomplete	"Payment 3 of 36" — 3 < 4; AI was correct	May 4
1182939	Comcast	Val_FourMonthsService, Val_InstallmentPlanPayoff	Incomplete	Complete	14 payments remaining = 10 made; balance $816.69	May 7
1194399	T-Mobile	Val_FourMonthsService	Complete	Incomplete	"Payment 2 of 24" — Ryan Nelson (EIP count)	May 6
1195324	T-Mobile	Val_FourMonthsService	Complete	Incomplete	Same as 1194399	May 6
1193578	T-Mobile	Val_NotTabletWearable, Val_InstallmentPlanPayoff	Complete	Incomplete	AirPods 4 + USB-C adapter (accessories, not phones)	May 7
1215265	T-Mobile	Val_FourMonthsService	Complete	Incomplete	"Payment 3 of 24" — same Ryan Nelson principle	May 7
1217831	T-Mobile	Val_FourMonthsService	Complete	Incomplete	Same as 1215265	May 7

Total: 11 corrections. FourMonths rule (EIP count on current device) accounted for 5 of 11.
 
7. NR Analysis — Why Claims Route to Needs Review
NR Rate by Carrier — B1 vs B2
Carrier	B1 NR Rate	B1 n	B2 NR Rate	B2 n	Primary Cause	Fixable?
T-Mobile	11.2% (11/98)	98	15.0% (15/100)	100	CTN not found; image quality on dense family bills; blobs missing	Partial — Fix N/O/P applied; residual structural
Verizon	13.5% (13/96)	96	22.0% (22/100)	100	Installment not visible; summary pages; account-level billing	Partial — Fix K/M applied; residual structural
Spectrum	72.3% (34/47)	47	N/A (on hold)	—	Bill format — CTN and EIP not on summary page	Structural — business decision needed
Comcast	79.6% (39/49)	49	N/A (on hold)	—	No Statement Date on Xfinity combined statements	Structural — business decision needed

B2 NR rate higher than B1 because B2 claims are fresh/unseen — more variety in bill formats, document types, and edge cases not seen during prompt tuning.
Notable B2 Fresh Eval Patterns
Carrier	Pattern	Count	Notes
T-Mobile	False NR (AI=NR, Human=Complete)	1	Pipeline should have passed — missed extraction on valid bill
T-Mobile	AutoWrong (AI=Complete, Human=Incomplete)	3	AI over-approved; installment or device rule incorrect
T-Mobile	AutoWrong (AI=Incomplete, Human=Complete)	2	AI under-approved; missed valid installment evidence
Verizon	False NR (AI=NR, Human=Complete)	4	Worth blob inspection — likely extractable
Verizon	AutoWrong (AI=Incomplete, Human=Complete)	4	Under-approved; possible account-level buyout not extracted
Verizon	AutoWrong (AI=Complete, Human=Incomplete)	2	Over-approved; rule logic incorrect on these claim types

Phase 0 Inspection Queue (Resolved Items)
Claim	Carrier	Phase	Status	Resolution
1197959	Verizon	0D	✅ RESOLVED	Fix M (activity log strip) — both 1197959 and 1197989 → Passed in run_123
1197989	Verizon	0D	✅ RESOLVED	Same as above
1197929	Verizon	0D	✅ RESOLVED	Fix J (vision 429 retry) — now Partial_High (run_109)
1197746	Verizon	0D	✅ RESOLVED	Fix J — now Partial_High (run_109)
1194618	Verizon	0B	⏳ Pending	Not yet blob-inspected
1197232	Verizon	0B	⏳ Pending	Not yet blob-inspected
1197843	T-Mobile	0B	⏳ Pending	Markdown scanner false positive identified — NR (run_089 → run_092)
1193593	T-Mobile	0B	⏳ Pending	Fix P partially helps (~50% pass rate); volatile
1186291	Comcast	0C	⏳ On hold	On hold until Comcast deprioritization resolved
1185847	Comcast	0C	⏳ On hold	Same
1182940	Comcast	0C	⏳ On hold	Same

 
8. Edge Cases & Known Limitations
Full edge case reference: IDP_Handoff_Guide_VXXXXXs_2026-05-28.docx (Section 7). Summary below.
T-Mobile Edge Cases
ID	Scenario	Pipeline Behavior	Outcome
EC-001	"Final charge (line cancelled)"	Auto-Pass FourMonths regardless of payment number	Pass (Ryan Nelson, May 6)
EC-002	Completed installment (12/12, $0)	Fail — no active balance	Fail (correct)
EC-003	Payment 2 of 24 submitted	Fail — < 4 months	Fail (Ryan Nelson, May 6)
EC-004	AirPods 4 on family account bill	Fail — Accessory classification	Fail (correct)
EC-005	Voice-only removed line — no device	NR — no installment to validate	NR (correct)
EC-006	Dense 9-line photographed family bill	CTN extraction volatile (~50% success)	Unreliable (no fix without higher-res source)
EC-007	Blobs only in attrewardcenter	Fallback container checked (Fix N)	Pass if found
EC-008	EXIF-rotated JPEG	Rotation baked + resize before GPT (Fix O)	Normal extraction
EC-009	Human reviewer overrides correct AI	Counts as AutoWrong	Cannot resolve in code

Verizon Edge Cases
ID	Scenario	Pipeline Behavior	Outcome
EC-010	Account-level Device Payment Buyout	Accepted as valid installment (Fix K/Q)	Pass (Ryan Nelson, May 14)
EC-011	Store receipt submitted	Fail — not a valid bill	Fail (correct)
EC-012	4th sibling CTN on shared blobs	NR — CTN not found in any page	NR (structural limitation)
EC-013	Expired bill (2014–2015)	Fail — exceeds 120-day window	Fail (correct)
EC-014	"Provisional Device ID 5G Core"	Classified as Phone (current behavior)	Ambiguous — pending Ryan Nelson ruling
EC-015	Transfer-of-service letter	Fail — no bill data	Fail (correct)
EC-018	Large PDF with activity logs	Activity sections stripped before GPT (Fix M)	Normal extraction

Systematic Pipeline Edge Cases
Issue	Carriers	Mitigation Applied	Residual Risk
OpenAI vision rate limit (HTTP 429)	Both	Fix J — retry + 3s throttle	None — resolved
Zscaler proxy truncation (large JPEG)	T-Mobile	Fix O — resize to 2048px max	Low — fixed for known cases
GPT context overflow (large PDF)	Verizon	Fix M — strip activity sections	Low — fixed for 19-page bills
blobs in wrong container	T-Mobile	Fix N — attrewardcenter fallback	Low — dual-container search active
Dense photographed family bills	T-Mobile	Fix P (partial) — CTN hint injection	Volatile for 4 claims (account 996097665)
GPT non-determinism on borderline images	Both	None — inherent to LLM	~1–2% variance per run

 
9. Carrier Configuration & Data [UPDATE]
Test Database Claims (as of May 2026)
Carrier	Claims in Test DB	Type	Prompt Version	Latest Run	Best All-In Acc
T-Mobile	5,643	Consumer (filtered)	v1.3.3	run_142 (B2)	91.7% (run_131, volatile)
Verizon	8,450	Consumer (filtered)	v1.3.1	run_144 (B2)	93.5% (run_123, B1 curated)
Spectrum Mobile	1,304	Consumer	v1.2.0	run_080	27.7% (structural NR)
Comcast/Xfinity	524	Consumer	v1.2.0	run_079	18.4% (structural NR)

Production Claim Volume (2026 YTD)
Carrier	YTD Claims	Priority	Notes
Verizon	150,249	Primary	Highest volume; B2 72.0% all-in
T-Mobile	84,387	Primary	B2 80.0% all-in; Cory confirmed good enough
Spectrum	12,298	Secondary	On hold — high NR rate; prompts need work
Comcast	2,518	Secondary	On hold — structural NR; business decision needed
Optimum	242	Low	No prompt developed
AT&T	205	Low	Deprioritized — low volume
Cox	155	Low	No prompt developed

Active Prompt Versions
Carrier	Active Version	Key Capabilities	Version History
T-Mobile	v1.3.3	EIP, Removed lines, Final charge, CTN hint, attrewardcenter fallback	v1.0.0→v1.1.0→v1.2.0→v1.3.0→v1.3.1→v1.3.2(reverted)→v1.3.3
Verizon	v1.3.1	Buyout (X-Y), 5G Core, DPA, store receipt rejection, account-level buyout JPEG path	v1.0.0→v1.1.0→v1.2.0→v1.3.0→v1.3.1
Spectrum	v1.2.0	FourMonths INSTALLMENT PROGRESS section	v1.0.0→v1.1.1→v1.2.0
Comcast	v1.2.0	FourMonths, CopyOfBill (structural NR unresolved)	v1.0.0→v1.1.1→v1.1.2→v1.2.0

v1.3.2 T-Mobile was a regression — added REMOVED-LINE section that broke family account bills. Reverted to v1.3.1 content as v1.3.3.
 
10. Database Schema
Database: ETFClaims_Validation_Test_DB (Azure SQL serverless — auto-pauses when idle)
Data_Historical_Archive — Key Columns (Golden Dataset)
Column	Type	Description
ETFSwitcherOrdersID	INT PK	Claim ID — links to AI_Evaluation_Results
BillPhone	VARCHAR	Customer CTN — the phone number being validated (10-digit)
ServiceProvider	VARCHAR	Carrier name (T-Mobile, Verizon, Spectrum, etc.)
ServiceProviderOther	VARCHAR	Fallback carrier field
DocumentNames	VARCHAR	Semicolon-separated blob names for this claim's documents
CreatedDate	DATETIME	Claim submission date — used in Val_BillDateValid 120-day window
Distribution_Status	VARCHAR	Passed through to AI_Evaluation_Results as-is
Val_CopyOfBill	VARCHAR	Human-validated ground truth for CopyOfBill rule
Val_CTNMatch	VARCHAR	Human-validated ground truth for CTNMatch rule
Val_InstallmentPlanPayoff	VARCHAR	Human-validated ground truth for InstallmentPlanPayoff rule
Val_FourMonthsService	VARCHAR	Human-validated ground truth for FourMonthsService rule
Val_BillDateValid	VARCHAR	Human-validated ground truth for BillDateValid rule
Val_NotTabletWearable	VARCHAR	Human-validated ground truth for NotTabletWearable rule

AI_Evaluation_Results — Key Columns
Column Group	Columns	Notes
Identity	EvaluationID (INT IDENTITY PK)	Auto-incremented
Claim ref	ETFSwitcherOrdersID, ModelName, EvaluationRunID, CreatedAt	Join to Data_Historical_Archive
Performance	ProcessingTimeMs, EstimatedCostUSD	Per-claim cost tracking
Decision	AI_Verification_Decision, AIStatusMatch, Distribution_Status	Needs_Review / Passed / Partial_High / Partial_Low
Per rule (×6)	Val_*_Status, Val_*_Evidence, Val_*_Confidence	18 columns — Complete / Incomplete / N/A per rule
Summary	RulesMatched, RulesExtracted, HasConflict, ConflictDetails	Aggregated rule match counts
Error	ErrorMessage	Extraction failure details

AI_Evaluation_Runs — Key Columns
Column	Description
RunID	Format: run_001, run_002, … — auto-incremented from MAX(RunID)+1
StartedAt / CompletedAt	Run duration tracking
ClaimsProcessed / ClaimsSkipped / ClaimsWithErrors	Run summary counts
ModelsUsed	Comma-separated model names
Parameters	JSON: carrier, limit, skip_processed flags
Status	Running / Completed / Failed
DiscrepancyCount / DiscrepancyClaimIDs / DiscrepancyDetails	AI vs human mismatch tracking

Config Tables
Table	Purpose	Key Columns
Config_Prompts	Carrier-specific extraction prompts	PromptKey, PromptBody, Version, UpdatedAt
Config_Parameters	Pipeline parameters	BillDateWindowDays=120, FourMonthsMinPayments=4, IneligibleDevicePatterns, PhoneIndicatorPatterns
Config_ModelEndpoints	Model deployment configs	ModelKey, model_id_or_deployment, Endpoint, APIKey

 
11. Cost & Performance
Per-Claim Cost by Carrier
Run	Carrier	n	Total USD	USD/claim	Avg ms/claim	Notes
run_074	T-Mobile	49	$6.02	$0.123	18,891ms	TM baseline cost
run_075	Verizon	48	$22.95	$0.478	17,778ms	⚠ 4× more expensive than TM — longer PDFs
run_080	Spectrum	47	~$2.97	$0.063	14,338ms	Cheap due to high NR rate
run_079	Comcast	49	~$3.78	$0.077	18,300ms	Similar to Spectrum

Verizon is 4× more expensive than T-Mobile. Likely cause: 19-page PDFs = more input tokens. Fix M (activity strip) may reduce this — not yet re-measured.
Annual Cost Estimates (2026 YTD Rates)
Carrier	YTD Claims	Rate	Annual Cost Est.
T-Mobile	84,387	$0.12/claim	~$10,100
Verizon	150,249	$0.48/claim	~$72,100 (anomaly — must investigate after Fix M)
Spectrum	12,298	$0.06/claim	~$740
Comcast	2,518	$0.08/claim	~$200
TOTAL	249,452		~$83,100 (VZ anomaly = 87% of cost)

 
12. Business Decisions
Resolved
Decision	Resolution	Authority	Date
Verizon buyout format (X-Y) = valid FourMonths?	YES — use X as payment count	Ryan Nelson	May 6, 2026
Payment 2 of 24 = EIP count or service tenure?	EIP count on current device	Ryan Nelson	May 6, 2026
Final charge (line cancelled) = FourMonths pass?	YES if remaining balance > 0 — proves active EIP	Ryan Nelson	May 7, 2026
Account-level Device Payment Buyout = valid installment?	YES — valid even without per-CTN association	Ryan Nelson	May 14, 2026
Not-in-good-standing = disqualify if remaining balance > 0?	NO — past-due flag only; remaining balance does not disqualify	Ryan Nelson	May 14, 2026
Go/No-Go on further pipeline refinement?	NO-GO — current pipeline is accepted as good enough for business use and VXXXXXs integration. No further fixes or prompt refinement planned.	Cory Shounick	May 27, 2026
T-Mobile accuracy good enough?	YES — Cory confirmed TM acceptable at current state	Cory Shounick	May 27, 2026
Accepted accuracy floor?	~88% all-in (B1 curated); B2 fresh eval also accepted as the honest production baseline	Josh (VP) + Cory	May 20–27, 2026
AirPods 4 as installment plan device?	NO — Accessory, not phone; claim ineligible	Blob inspection	May 7, 2026

Pending — Action Required
Decision	Impact	Owner	Status
"Provisional Device ID 5G Core" — eligible phone or 5G gateway?	~3 known misclassifications in test set; 106 valid phone claims use same label	Ryan Nelson	⏳ Pending
Comcast structural NR (79.6%) — accept or require different doc?	Business process change if not accepted	Cory / Chris Scupham	⏳ On hold
Verizon cost anomaly ($0.48 vs $0.12 T-Mobile)	Must understand before production cost model	Sogo (investigate)	⏳ Pending
Go/No-Go criteria for VXXXXXs POC launch	No-Go on refinement — current state IS the handoff baseline	Cory	✅ RESOLVED 2026-05-27
gpt-4.1 vs gpt-5.x benchmark	On hold — no active refinement planned	Cory + Sogo	⏳ On hold per No-Go decision

 
13. VXXXXXs Integration
Integration Timeline
Date	Event
May 21, 2026	VXXXXXs training session delivered — IDP pipeline overview and accuracy results
May 21, 2026	Email sent to Abhishant (VXXXXXs) with training slides
May 27, 2026	Cory back from vacation — alignment meeting held
May 27, 2026	VXXXXXs presented updated Azure Functions microservices architecture (Request Flow)
May 27, 2026	Decision: handoff assets are prompt templates + extraction rules logic
May 27, 2026	Cory requested VXXXXXs review rules, code, and PowerPoint and provide expert feedback
May 28, 2026	IDP extraction rules & edge cases handoff guide drafted (IDP_Handoff_Guide_VXXXXXs_2026-05-28.docx)
May 30, 2026	Target: share extraction rules document with VXXXXXs

What XXXXX X Is Handing Over to VXXXXXs
Asset	Description	Location
T-Mobile Extraction Prompt	GPT-4.1 prompt v1.3.3 — tuned for T-Mobile bill structure	Azure SQL: Config_Prompts (OpenAI_Extraction_TMobile)
Verizon Extraction Prompt	GPT-4.1 prompt v1.3.1 — tuned for Verizon bill structure	Azure SQL: Config_Prompts (OpenAI_Extraction_Verizon)
System Prompt	OpenAI system role instruction for extraction	Azure SQL: OpenAI_Extraction_System
Extraction Rules Logic	6 validation rules with Pass/Fail/NR conditions + edge cases	This document + IDP_Handoff_Guide_VXXXXXs_2026-05-28.docx
Device Classification Logic	Keyword-based device classifier + GPT-4.1 fallback	production/models/device_classifier.py
Golden Dataset	Human-validated claims for eval + blob documents	Azure SQL Data_Historical_Archive + etfswitcher/attrewardcenter containers

Access Requirements for VXXXXXs
Resource	Type	Access Level Needed	Notes
Azure SQL Database	Data_Historical_Archive, AI_Evaluation_Results, AI_Evaluation_Runs	db_datareader (read-only)	Contains production claim history
Azure Blob Storage	etfswitcher container	Storage Blob Data Reader	Primary bill documents
Azure Blob Storage	attrewardcenter container	Storage Blob Data Reader	Secondary bill documents (T-Mobile)
Azure OpenAI	GPT-4.1 deployment	API access	claim-processor-v1 resource
Azure Document Intelligence	prebuilt-layout model	API access	For OCR Extraction API

NOTE: These are production data resources. Granting external vendor access requires Cory/security approval. Discuss with Cory whether to provide direct access or a sanitized copy.
Open Integration Questions
#	Question	Impact	Status
Q1	Direct production access vs. isolated copy of Golden Dataset?	Security / compliance decision	Pending Cory/security
Q2	Who maintains the prompt templates after handoff?	Accuracy ownership going forward	Pending Cory alignment
Q3	Which carriers are in scope for Phase 1 POC?	Defines integration scope	Pending Cory alignment
Q4	Go/No-Go criteria — accuracy floor + carrier scope for POC launch?	Defines handoff readiness	Pending Cory alignment
Q5	GitHub access for code migration — when granted?	Required for VXXXXXs code review	Pending IT

 
14. Improvement Roadmap — Phases 0–4
NOTE: All improvement phases (0–4) are ON HOLD as of 2026-05-27. Cory confirmed No-Go on further refinement — the current pipeline is the accepted baseline for VXXXXXs integration. Phases are documented below for reference only.
Phase 0 — Diagnostics (ON HOLD)
Step	Task	Status
0B	Blob inspect TM 1197843, 1193593; VZ 1194618, 1197232	⏳ On hold — No-Go decision; not blocking integration
0C	Blob inspect Comcast 1186291, 1185847, 1182940	⏳ On hold — Comcast deprioritized
0D	Re-inspect 4 former VZ Extraction_Error claims now NR	✅ RESOLVED via Fix J + Fix M (run_109, run_123)

Phase 1 — Test Data Corrections (ON HOLD)
On hold per No-Go decision. Would be: apply corrections confirmed by Phase 0 blob inspections.
Phase 2 — Targeted Prompt Fixes (ON HOLD)
Fix	Target Claims	Status
2A — Verizon tabular billing	1197959, 1197989	✅ RESOLVED by Fix M — no further action needed
2B — TM 1193593 Removed-line CTN	1193593	⏳ On hold — No-Go decision
2C — Verizon 1194618 + 1197232	1194618, 1197232	⏳ On hold — No-Go decision
2D — Comcast FourMonths	1186291, 1185847	⏳ On hold — Comcast deprioritized

Phase 3 — Pipeline Infrastructure (ON HOLD)
Fix	Approach	Status
3A — PDF text extraction fallback	pdfplumber pre-processing for large PDFs	⏳ On hold — No-Go decision
3B — Multi-page document routing	Try next blob before NR if CTN not found	⏳ On hold — No-Go decision
3C — NR_Trigger_Code column	Structured INT column (1–5) in AI_Evaluation_Results	⏳ On hold — No-Go decision

Phase 4 — Scale & Model Validation (ON HOLD)
Task	Status
4A — Expand eval to 150–200 claims/carrier	⏳ On hold — No-Go decision
4B — gpt-4.1 vs gpt-5.x benchmark	⏳ On hold — No-Go decision

 
15. Known Issues & Monitoring
Issue	Status	Resolution Path
TM B2 all-in 80.0% below 88% floor	✅ ACCEPTED — No-Go on refinement	Cory confirmed current state is good enough (2026-05-27). No further action.
VZ B2 all-in 72.0% below 88% floor	✅ ACCEPTED — No-Go on refinement	Same decision — current pipeline is the accepted baseline for VXXXXXs.
VZ B2 false NRs (4 claims, AI=NR/Human=Complete)	⏳ Not yet blob-inspected	Blob inspection when bandwidth allows
Provisional Device ID 5G Core (VZ) ambiguity	⏳ Pending Ryan Nelson ruling	OI-001 — same label for phone and 5G gateway
Dense photographed TM family bills (4 claims)	Partially mitigated (Fix P ~50%)	No reliable fix without higher-res source images from submitter
Comcast 79.6% NR — structural	⏳ On hold per Cory	Business decision needed on doc type requirements
Verizon cost anomaly ($0.48 vs $0.12 TM)	⏳ Not yet investigated	Query token counts from run_091; may improve after Fix M
Small eval sample n=48–100 — variance ±3–6pp	Active — Phase 4A planned	Expand to 150–200 claims after integration milestone
No structured NR_Trigger_Code in results	Phase 3C planned	Add INT column (1–5) for programmatic NR triage
DI → OpenAI Vision migration not started	Architecture decision pending	Scope after Phase 4B benchmark; VXXXXXs to lead
GitHub access for VXXXXXs not yet granted	⏳ Pending IT	Inform Cory when granted
No monitoring / alerting in production	Not implemented	Required for production — Azure Monitor / App Insights

 
16. How to Run
Standard Evaluation Run
Command	What It Does
python -m production.run_evaluation --limit 50 --models openai --carrier "T-Mobile"	Fresh T-Mobile eval (50 claims, newest first; NOT EXISTS filter skips already-evaluated)
python -m production.run_evaluation --limit 50 --models openai --carrier "Verizon" --no-skip-processed	Re-run 50 Verizon claims (overwrites prior results)
python -m production.run_evaluation --etf-ids 1197959 1197989 --models openai --carrier "Verizon"	Targeted re-run of specific claim IDs
python AzureIDP-Pilot-Py/check_runs.py	Query run status and result counts from DB
python AzureIDP-Pilot-Py/delete_stale_runs.py	Delete empty/stale run entries from AI_Evaluation_Runs + AI_Evaluation_Results

Blob Inspection
Command	What It Does
python AzureIDP-Pilot-Py/debug_1193583_1193593.py	Debug dense TM family bill (1193583, 1193593)
python AzureIDP-Pilot-Py/debug_1193887.py	Debug VZ claim 1193887
python AzureIDP-Pilot-Py/debug_batch_1197929.py	Debug VZ batch claim 1197929
python AzureIDP-Pilot-Py/debug_vz_claims.py	Debug specific VZ claims
python AzureIDP-Pilot-Py/debug_noproxy.py	Debug with proxy bypass

Prompt Management
1.	Edit LocalDBTables/Config_Prompts.csv — update PromptBody and bump Version (vMAJOR.MINOR.PATCH)
2.	Push to DB via push_prompts script (carrier-specific push script)
3.	Verify: SELECT PromptKey, Version, UpdatedAt FROM Config_Prompts
4.	Re-run affected carrier eval — check no regression on existing claims
5.	Update accuracy_progress_log.md with new run results
Test Data Corrections
6.	Add entry to fix_test_data_errors.py: claim ID, rule, old value, new value, confirmed-by, date
7.	Run: python fix_test_data_errors.py
8.	Re-run affected carrier eval to confirm claim now AutoCorrects
9.	Document correction in accuracy_progress_log.md and this document
Document Generation
Script	Output	What It Generates
docs/generate_living_doc.py	docs/IDP_Living_Documentation_2026-05-28.docx	This document
AzureIDP-Pilot-Py/generate_extraction_rules_docx.py	docs/IDP_Handoff_Guide_VXXXXXs_2026-05-28.docx	VXXXXXs handoff guide
AzureIDP-Pilot-Py/generate_weekly_report_2026_05_29.py	docs/Weekly_Report_IDP_2026-05-29.docx	Weekly report (Word)
AzureIDP-Pilot-Py/generate_weekly_pptx_2026_05_29.py	docs/Weekly_IDP_Report_2026-05-29.pptx	Weekly report (PowerPoint)
AzureIDP-Pilot-Py/generate_standup_doc.py	docs/VXXXXXs_Standup_2026-05-21.docx	VXXXXXs standup Word doc
AzureIDP-Pilot-Py/generate_standup_pptx.py	docs/VXXXXXs_Standup_2026-05-21.pptx	VXXXXXs standup slide deck

 
17. VXXXXXs Handoff Readiness
Component	Status	Notes
Pipeline core	✅ Production-ready	Per-claim commits, NR routing, all 4 carriers, NOT EXISTS fresh eval filter
T-Mobile B1 accuracy	✅ 88.8% (n=98)	Above 88% floor; Cory confirmed good enough
T-Mobile B2 accuracy	✅ 80.0% (n=100)	Accepted — No-Go on refinement; Cory confirmed good enough (2026-05-27)
Verizon B1 accuracy	✅ 83.3% (n=96)	Accepted — No-Go on refinement; current state is the handoff baseline
Verizon B2 accuracy	✅ 72.0% (n=100)	Accepted — No-Go on refinement; B1/B2 gap documented and acknowledged
Spectrum accuracy	⚠️ 27.7% (n=47)	High NR structural — on hold per Cory
Comcast accuracy	⚠️ 18.4% (n=49)	High NR structural — on hold; business decision needed
Prompt versioning	✅ Done	SQL-backed; hot-swappable without code deploy
Test data integrity	✅ Done	11 corrections applied; all confirmed
Extraction rules documentation	✅ Done	IDP_Handoff_Guide_VXXXXXs_2026-05-28.docx prepared
VXXXXXs architecture review	✅ Done	Reviewed 05/27; Azure Functions microservices confirmed
Data access (Golden Dataset)	⏳ Pending approval	Production data — Cory/security must approve VXXXXXs access
GitHub code access	⏳ Pending IT	Code migration blocked until access granted
Go/No-Go criteria aligned	⏳ Pending Cory	Accuracy floor + carrier scope for POC launch not yet confirmed
Cost tracking	✅ Done	EstimatedCostUSD per claim in AI_Evaluation_Results
Verizon cost anomaly	⏳ Not investigated	Must resolve before production cost model
Monitoring / alerting	❌ Not implemented	Required for production — Azure Monitor / App Insights
Containerization	❌ Not implemented	VXXXXXs to scope (Azure Container Apps or Function App)
DI → OpenAI Vision migration	❌ Architecture pending	Post Phase 4B model benchmark

Go/No-Go Decision — May 27, 2026
Cory Shounick confirmed on May 27, 2026 that the current pipeline is good enough for the business use case and for VXXXXXs to work with. No further prompt refinement, pipeline fixes, or accuracy improvement work is planned. The current state — B1: TM 88.8% (n=98) / VZ 83.3% (n=96); B2: TM 80.0% (n=100) / VZ 72.0% (n=100) — is the accepted baseline for the VXXXXXs integration.

Recommended Next Steps (as of May 28, 2026)
10.	Share extraction rules & edge cases document with VXXXXXs by Fri 05/30/2026
11.	Resolve data access question: direct production access vs. isolated copy for VXXXXXs (pending Cory/security approval)
12.	Confirm GitHub access for VXXXXXs code migration; notify Cory when granted
13.	Await VXXXXXs expert feedback on architecture, rules, and code
14.	Await Cory's additional context on new initiatives (agent solutions, Copilot Studio automations)
15.	Get Ryan Nelson ruling on Provisional Device ID 5G Core (VZ) ambiguity — only outstanding business rule

This is a living document. Update Sections 1 (accuracy summary), 4 (accuracy history), 7 (NR analysis), 9 (carrier data), 12 (business decisions), 13 (VXXXXXs integration), 15 (known issues), and 17 (handoff readiness) after each major run or milestone. Contact: sogo.alonge@groupo.com


=====================================||========================================================================
IDP Pipeline: Extraction Rules, Edge Cases & Documentation Guide
Carriers in scope: T-Mobile · Verizon  
Prompt versions: T-Mobile v1.3.3 · Verizon v1.3.1  
AI model: GPT-4.1 (Azure OpenAI) · OCR: Azure Document Intelligence

1. Executive Summary
XXXXX X's Intelligent Document Processing (IDP) pipeline automates the validation of ETF (Early Termination Fee) switch claims. When a customer switches carriers and submits a carrier bill to claim an ETF reimbursement, the pipeline extracts key data from that bill and applies 6 eligibility rules to determine whether the claim should be approved, denied, or sent for human review.
XXXXX X is handing over two core assets to VXXXXXs for integration into the production architecture:
1. Carrier-specific prompt templates: the GPT-4.1 extraction prompts tuned for T-Mobile and Verizon bills
2. Extraction rules & edge case logic: the 6 validation rules, business rulings, and known exceptions documented in this guide
VXXXXXs will wrap these into their own Azure Functions microservices architecture (OCR Extraction API + AI Extraction API + Rules Engine API). This document is the guide reference for implementing that logic correctly.

2. Business Context
What the pipeline validates:  
Each ETF claim has a phone number (CTN) associated with it. The customer submits a carrier bill showing their installment plan and service history. The pipeline checks that:
•	The document is a genuine copy of the bill
•	The phone number on the claim matches a line on the bill
•	The device has an active installment plan (money still owed to the carrier)
•	The customer has been on service for at least 4 months
•	The bill is recent (within 120 days of claim submission)
•	The device is a phone — not a tablet, wearable, or accessory
Who sets the business rules: Ryan Nelson (XXXXX X) is the approver for claim eligibility decisions.
Accepted accuracy floor: ~88% all-in accuracy. Both T-Mobile and Verizon are currently evaluated against this floor. All-in accuracy counts Needs Review (NR) claims as misses; it is the production-representative metric.
Active carriers and volume (2026 YTD):
Carrier	YTD Claims	Priority	Prompt Status
Verizon	150,249	Primary	v1.3.1 — active
T-Mobile	84,387	Primary	v1.3.3 — active
Spectrum	12,298	Secondary	v1.2.0 — on hold
Comcast	2,518	Secondary	v1.2.0 — on hold
*Note for VXXXXXs: The Golden Dataset (Azure SQL + Blob Storage) includes both auto-corrected claims (where AI matched human labels) and manually validated test cases (where human labels were corrected after blob inspection). See Section 10 for the full pass/fail/NR breakdown per batch. For full project history and engineering context, refer to the supporting documents listed in Section 13.

3. Pipeline Architecture Overview
The pipeline processes one claim at a time through four stages:
Stage 1: Document Retrieval  
For each claim, the pipeline retrieves the carrier bill documents (PDFs and/or JPEGs) from Azure Blob Storage. The DocumentNames field in the claim record contains semicolon-separated blob names. Two containers are checked: primary (etfswitcher) and fallback (attrewardcenter).
Stage 2: OCR / Extraction  
•	PDF documents → Azure Document Intelligence (ADI) converts to markdown text → text is stripped of irrelevant sections (activity logs) → sent to GPT-4.1 for structured extraction
•	JPEG/image documents → sent directly to GPT-4.1 vision API (with EXIF rotation and resize pre-processing applied)
•	GPT-4.1 returns structured JSON: bill date, list of devices with CTN, device model, installment balance, and installment progress
Stage 3: Rules Evaluation  
The extracted JSON is passed to the rules engine along with the claim's phone number (BillPhone/CTN) and submission date. The 6 rules are evaluated and each receives a result: Complete (Pass), Incomplete (Fail), or None (cannot determine → NR).
Stage 4: Decision & Output  
The claim receives a final AI decision:
•	Passed: all 6 rules Complete
•	Partial_High: 5 of 6 rules match (off by 1)
•	Partial_Low: 4 or fewer rules match
•	Needs Review (NR): one or more rules return None; routed to human review queue
•	Extraction_Error: document processing failed entirely

4. Documentation Assets
The following assets are being provided to VXXXXXs:
Asset	Description	Format	Location
T-Mobile Extraction Prompt	GPT-4.1 prompt v1.3.3 — tuned for T-Mobile bill structure	Text (stored in Azure SQL Config_Prompts table)	DB: OpenAI_Extraction_TMobile
Verizon Extraction Prompt	GPT-4.1 prompt v1.3.1 — tuned for Verizon bill structure	Text (stored in Azure SQL Config_Prompts table)	DB: OpenAI_Extraction_Verizon
System Prompt	OpenAI system role instruction for extraction	Text	DB: OpenAI_Extraction_System
Device Classification Prompt	GPT-4.1 prompt for classifying device type (Phone/Tablet/Wearable/etc.)	Text	DB: Device_Classification
Extraction Rules Logic	6 validation rules with Pass/Fail/NR conditions	This document + source code	production/rules/validation_rules.py
Edge Cases Table	19 documented edge cases with carrier, condition, and expected behavior	This document (Section 7)	—
Device Classifier	Keyword-based device classification with GPT-4.1 fallback	Python source	production/models/device_classifier.py
Golden Dataset	Human-validated claims for T-Mobile and Verizon (eval sets)	Azure SQL + Blob Storage	Data_Historical_Archive table + etfswitcher / attrewardcenter containers


5. Extraction Schema: What to Extract
The AI extraction prompt instructs GPT-4.1 to return a structured JSON object. The following fields must be extracted from each carrier bill.
5.1 Top-Level Fields
Field	Type	Description	Required
bill_date	string (YYYY-MM-DD)	Date the bill was issued	Yes
carrier_name	string	Carrier identified on the bill	Yes
account_number	string	Customer account number	Optional
devices	array	List of devices/lines found on the bill	Yes
account_level_buyouts	array	Account-level Device Payment Buyout Charges (Verizon only)	Verizon only

5.2 Per-Device Fields (each item in `devices` array)
Field	Type	Description	Maps To
phone_number	string	CTN (10-digit phone number) for this line	Val_CTNMatch
device_model	string	Device name as printed on bill	Val_NotTabletWearable
installment_balance	string	Remaining balance on installment plan (e.g., "$441.63")	Val_InstallmentPlanPayoff
installment_progress	string	Payment number (e.g., "Payment 8 of 24")	Val_FourMonthsService

5.3 Account-Level Buyout Fields (Verizon only — `account_level_buyouts` array)
Field	Type	Description
amount	string	Buyout charge amount (e.g., "$364.86")
progress	string	Payment progress (e.g., "18 of 36")
* Important: The account_level_buyouts field is Verizon-specific only. T-Mobile does not use account-level buyout charges. T-Mobile installment data always appears as per-CTN entries in the                                          HANDSETS section. See EC-010 in Section 7 and IDP_Engineering_Innovations_2026-05-28.docx (Part 4, Innovation #22) for full implementation detail.

5.4 Where to Find the Data on the Bill
Carrier	Bill Section	Data Location
T-Mobile	HANDSETS section	Primary location for device model, installment balance, payment progress
T-Mobile	DETAILED CHARGES section	Secondary — some family account lines list installment data here instead
T-Mobile	THIS BILL SUMMARY	Bill date, account overview, removed lines
Verizon (PDF)	Equipment/Device section	Per-CTN installment details
Verizon (PDF)	Activity log sections	Strip before sending to GPT — adds 80K+ chars with no useful data
Verizon (PDF/JPEG)	Account-level section	Device Payment Buyout Charges (account-level, no per-CTN link)
Verizon (JPEG)	Multi-page visual scan	CTN may be on different page than installment detail


6. Validation Rules: Full Reference
6.1 Rules Summary Table
#	Rule	What It Validates	Pass Condition	Fail Condition	NR Condition
1	Val_CopyOfBill	Document is a genuine carrier bill	Any bill data successfully extracted	Store receipt, transfer letter, or non-bill document	Not applicable — always Pass or Fail
2	Val_CTNMatch	Claim phone number matches a line on the bill	Claim CTN found in extracted devices[]	CTN found near confirmed ineligible device (auto-fail)	CTN not found in any extracted device
3	Val_InstallmentPlanPayoff	Device has active installment plan with remaining balance	installment_balance > $0 OR "Final charge on cancelled line" present	Balance = $0 AND no cancelled-line language	Installment details not visible on document
4	Val_FourMonthsService	Customer on service ≥ 4 months	Payment number ≥ 4 of total	Payment number 1, 2, or 3	Payment number not extractable
5	Val_BillDateValid	Bill date within 120 days of claim submission	0 ≤ (submission_date − bill_date) ≤ 120 days	Bill date > 120 days old OR wrong year	Bill date cannot be parsed
6	Val_NotTabletWearable	Device is a phone, not a tablet/wearable/accessory	Device classified as "Phone"	Device classified as Tablet, Wearable, Hotspot, HomeInternet, or Accessory	Device type unrecognized AND CTN unmatched

6.2 Decision Logic
`
For each claim:
  1. Extract bill data (GPT-4.1)
  2. If extraction fails entirely → Extraction_Error (route to human)
  3. Evaluate all 6 rules
  4. If ANY rule returns None (cannot determine) → Needs Review (NR)
     Exception: Val_CopyOfBill never returns NR
  5. Count rules_matched (AI result == Human label):
     - 6/6 → Passed
     - 5/6 → Partial_High
     - 4/6 or fewer → Partial_Low
  6. Needs Review claims are NOT auto-approved or auto-denied
     They are queued for human reviewer
`
Important: NR is not a failure: it means the pipeline cannot make a confident decision. NR claims count against all-in accuracy because they require manual handling.
6.3 Rule Evaluation Order and Dependencies
Order	Rule	Depends On
1st	Val_CopyOfBill	Extraction success
2nd	Val_BillDateValid	bill_date extracted
3rd	Val_CTNMatch	devices[] extracted; claim BillPhone available
4th	Val_NotTabletWearable	device_model from matched CTN
5th	Val_InstallmentPlanPayoff	installment_balance from matched CTN
6th	Val_FourMonthsService	installment_progress from matched CTN

If Val_CTNMatch fails to find the claim CTN, rules 4–6 cannot be evaluated for a specific device → the claim routes to NR.

7. Edge Cases & Exceptions: Rules Database
Documentation reference for all known cases where standard rule logic does not apply or requires special handling. Implement all EC entries in the Rules Engine.
ID	Carrier	Rule(s)	Scenario	Trigger Condition	Pipeline Action	Outcome	Authority
EC-001	T-Mobile	Val_FourMonthsService	"Final charge (line cancelled)" on a cancelled line	installment_progress contains "final charge" AND "cancelled"	Auto-Pass FourMonths regardless of payment number	Pass	Ryan Nelson, 2026-05-06
EC-002	T-Mobile	Val_InstallmentPlanPayoff, Val_FourMonthsService	Completed installment plan — $0 remaining	Payment X of X (e.g., 12/12); installment_balance = $0	Fail — no active balance	Fail (correct)	No ruling needed — plan paid off
EC-003	T-Mobile	Val_FourMonthsService	Payment 2 of 24 submitted as ETF claim	installment_progress = "Payment 2 of 24" (or 1 or 3)	Fail — < 4 months service	Fail (correct)	Ryan Nelson, 2026-05-06
EC-004	T-Mobile	Val_InstallmentPlanPayoff, Val_NotTabletWearable	AirPods or accessory on family account bill	CTN matched to non-phone line (AirPods 4, USB-C adapter, etc.)	Fail — Accessory classification	Fail (correct)	Standard rule; accessories ineligible
EC-005	T-Mobile	Val_InstallmentPlanPayoff	Voice-only removed line — no device	Line shown as "Removed — Voice" in bill summary; no HANDSETS entry	NR — no installment to validate	NR (correct)	No handset = no installment plan
EC-006	T-Mobile	Val_CTNMatch	Dense 9-line family account bill (photographed paper)	8+ handsets; compressed 48–60 KB JPEG; digits hard to read	CTN extraction volatile (~50% success)	Unreliable	No fix without higher-res source images
EC-007	T-Mobile	All rules	Blobs missing from primary container	DocumentNames blobs not in etfswitcher; present in attrewardcenter	Check fallback container before failing	Pass if found in attrewardcenter	Pipeline checks both containers
EC-008	T-Mobile	All rules	EXIF-rotated JPEG (photo taken sideways)	JPEG EXIF orientation = 6 (90° rotation required)	Apply rotation + resize before sending to GPT	Normal extraction	Pre-process all JPEGs for EXIF
EC-009	T-Mobile	Val_CopyOfBill, Val_BillDateValid	Human reviewer overrides AI extraction	AI extracts correctly; human marks rule Incomplete	Counts as AutoWrong in accuracy metrics	Human overrides pipeline	Cannot resolve in code — known limitation
EC-010	Verizon	Val_InstallmentPlanPayoff, Val_FourMonthsService	Account-level Device Payment Buyout Charge	Per-CTN installment not visible; account-level buyout present (e.g., "$364.86 · 18 of 36")	Accept account-level buyout as valid installment evidence	Pass	Ryan Nelson, 2026-05-14
EC-011	Verizon	Val_CopyOfBill	Verizon store receipt submitted instead of bill	Document is a retail purchase receipt, not a service bill	Fail — not a valid carrier bill	Fail (correct)	Store receipts have no service/installment data
EC-012	Verizon	Val_CTNMatch	4th sibling CTN on shared family account bill	4 claims share same JPEG docs; 4th CTN not visible on any page	NR — CTN not found	NR (acceptable limitation)	Structural — cannot resolve without more pages
EC-013	Verizon	Val_BillDateValid	Expired bill (3+ years old)	Bill date is 2014–2015; submission date is 2025–2026	Fail — bill exceeds 120-day window	Fail (correct)	Structural — old legacy documents
EC-014	Verizon	Val_NotTabletWearable	"Provisional Device ID 5G Core" device label	Device description = "Provisional Device ID 5G Core"	Currently classified as Phone (Pass)	Ambiguous — pending ruling	Same label = phone port-in placeholder OR 5G Home Internet gateway. Pending Ryan Nelson
EC-015	Verizon	Val_CopyOfBill	Transfer-of-service letter submitted	Document is a transfer letter, not a bill	Fail — no bill data extractable	Fail (correct)	Transfer letters are not service bills
EC-016	Both	All rules	OpenAI vision rate limit (HTTP 429)	Batch of 50+ claims; Azure OpenAI returns 429	Retry: 15s → 30s → 60s; 3-second throttle between vision calls	Normal extraction after retry	Root cause: RPM quota, not network
EC-017	Both	Val_CTNMatch, Val_InstallmentPlanPayoff	Account summary page submitted	Document is summary with no per-line installment breakdown	NR — CTN found but no installment details	NR (correct)	Route to human review
EC-018	Verizon	Val_InstallmentPlanPayoff	Large PDF with activity logs	19-page bill; Talk/Data/Message logs = 87% of ADI output (~99K chars)	Strip activity sections before GPT call → ~13K chars	Normal extraction after strip	Must implement activity log stripping
EC-019	Both	Val_NotTabletWearable	Unknown device description	Device string not in Phone or ineligible keyword lists	Route to NR — do NOT auto-fail	NR	Unknown ≠ ineligible; human review required
Key notes on the edge case table:
•	EC-010 (Account-Level Buyout) is Verizon ONLY. T-Mobile bills always show installment data as per-CTN line entries in the HANDSETS section. The account-level buyout pattern where a Device Payment Buyout Charge appears at the account level without a CTN link. This is a Verizon billing format only. See IDP_Engineering_Innovations_2026-05-28.docx (Part 4, Innovation #22) for the full technical implementation.
•	EC-009 (Human Override) applies to both carriers. During the initial phase of the program, Cory confirmed that failed cases should still be manually reviewed even if the AI marks them as Fail: human reviewers may override. This is expected behavior for the pilot phase.
•	For full edge case history, fix implementation details, and lessons learned, refer to: IDP_Engineering_Innovations_2026-05-28.docx (Parts 2–4).

8. Carrier-Specific Extraction Notes
8.1 T-Mobile
Prompt version: v1.3.3  
Document types: PDF (digital) and JPEG (phone-photographed paper bills)  
Current accuracy (B2 fresh eval — 100 unseen claims): 80.0% all-in · 94.1% decidable · 15.0% NR rate
Bill Section Reference
Bill Section	Content	Extraction Priority
THIS BILL SUMMARY	Account overview, bill date, removed lines	Bill date, removed-line detection
HANDSETS	Device model, installment balance, payment progress per line	Primary extraction target
DETAILED CHARGES	Per-line charges; sometimes include installment data for family accounts	Secondary — scan if HANDSETS section is incomplete

Key Extraction Rules for T-Mobile
•	Installment format: Payment X of Y followed by $BALANCE remaining
•	"Final charge (line cancelled)" text = auto-pass for FourMonths (EC-001)
•	CTN hint injection: append the claim CTN to the prompt to help GPT prioritize the correct line on dense family account bills
•	Always scan both HANDSETS and DETAILED CHARGES sections — do not stop at the first match
Document Handling Notes
Issue	Handling
Blobs only in attrewardcenter	Check fallback container (EC-007)
EXIF-rotated JPEG	Apply rotation + resize to max 2048px before GPT (EC-008)
Large full-res JPEG (> 3MB encoded)	Resize to max 2048px longest side to avoid proxy truncation
Dense photographed family bill	CTN extraction may be unreliable — flag for monitoring (EC-006)


8.2 Verizon
Prompt version: v1.3.1  
Document types: PDF (digital) and JPEG (multi-page phone photos)  
Current accuracy (B2 fresh eval — 100 unseen claims): 72.0% all-in · 92.3% decidable · 22.0% NR rate
Bill Section Reference
Bill Section	Content	Extraction Notes
Equipment / Devices section	Per-CTN installment details	Primary extraction target
Talk / Data / Message activity logs	Call logs, usage history	Must be stripped before sending to GPT — adds 80K+ useless chars
Account-level section	Device Payment Buyout Charges	Extract as account_level_buyouts[] — valid installment evidence (EC-010)

Account-Level Buyout Extraction (Verizon-specific)
When a customer's per-CTN installment line is not visible, check for an account-level Device Payment Buyout Charge. These appear in ADI HTML-format markdown as:
`
<td>Agreement ID</td><td>$364.86</td>
<td>18 of 36</td>
`
Extract: amount = $364.86, progress = 18 of 36. Treat as valid installment evidence per EC-010.
Document Handling Notes
Issue	Handling
Large PDF (19+ pages)	Strip Talk/Data/Message activity sections before GPT — 99K → ~13K chars (EC-018)
Multi-page JPEG	GPT processes each page separately; CTN and installment may be on different pages
Store receipt submitted	Reject — not a valid bill (EC-011)
Transfer letter submitted	Reject — not a valid bill (EC-015)


9. Device Classification Rules
The device classifier determines Val_NotTabletWearable. Classification is keyword-based with a GPT-4.1 fallback for unrecognized devices.
9.1 Classification Table
Classification	Val_NotTabletWearable	Examples	Behavior
Phone	Pass	iPhone, Samsung Galaxy S/Z, Google Pixel, OnePlus, Moto G/Edge	Eligible — claim proceeds
Tablet	Fail	iPad, Samsung Galaxy Tab, Surface	Auto-fail — claim denied
Wearable	Fail	Apple Watch, Galaxy Watch, Galaxy Fit, Gear	Auto-fail — claim denied
Hotspot	Fail	MiFi, Jetpack, Mobile Hotspot	Auto-fail — claim denied
HomeInternet	Fail	5G Home Internet gateway, Inseego gateway	Auto-fail — claim denied
Accessory	Fail	AirPods, earbuds, USB-C adapter	Auto-fail — claim denied
Unknown	NR	Unrecognized device description	Route to NR — do NOT auto-fail

9.2 Keyword Patterns
Ineligible (auto-fail) keywords:  
watch, tablet, ipad, tab , galaxy tab, surface, airpods, buds, earbuds, band, fit, gear, hotspot, mifi, jetpack, sync up
Phone (auto-pass) keywords:  
phone, iphone, galaxy s, galaxy z, pixel, oneplus, moto g, moto edge
Rule: Unknown devices route to NR for human review — they are never auto-failed. Only confirmed ineligible keyword matches auto-fail.

10. Accuracy Benchmarks
10.1 Curated Eval (Claims Used During Prompt Tuning)
Carrier	n	Pass	Fail (AutoWrong)	NR	All-In Acc	Decidable Acc	NR Rate
T-Mobile	98	87 (88.8%)	5 (5.1%)	6 (6.1%)	88.8%	100.0%	6.1%
Verizon	96	80 (83.3%)	4 (4.2%)	12 (12.5%)	83.3%	100.0%	12.5%
*B1 is the curated eval set used during prompt development. Prompts were tuned against these claims. 0 AutoWrong on decidable claims for both carriers. The Golden Dataset includes both auto-corrected and manually validated test cases

10.2 Fresh Eval (Unseen Claims: Production Representative)
Carrier	n	Pass	Fail (AutoWrong)	NR	All-In Acc	Decidable Acc	NR Rate
T-Mobile	100	80 (80.0%)	5 (5.0%)	15 (15.0%)	80.0%	94.1%	15.0%
Verizon	100	72 (72.0%)	6 (6.0%)	22 (22.0%)	72.0%	92.3%	22.0%
B2 uses previously unseen claims: prompts were tuned on B1 claims. Go/No-Go decision confirmed May 27, 2026: this is the accepted baseline.


11. NR (Needs Review) Trigger Reference
NR claims require human review and count against all-in accuracy. Understanding NR triggers is critical for planning the human-in-the-loop workflow.
NR Trigger	Root Cause	Carrier	Typical Frequency	Resolvable?
Bill date not extractable	Degraded document; non-bill document	Both	Low	Partially — better OCR may help
CTN not found in extracted devices	Summary page; poor image quality; blobs missing	Both	Medium-High	Partially — EC-007, EC-008 mitigations apply
Installment details not visible	Summary page; account-level bill	Both	High — VZ 22%, TM 15%	Partially — EC-010 (account-level buyout) reduces VZ NR
Installment progress < 4 months AND no balance	Partial extraction on borderline doc	Both	Low	No
Device type unknown and CTN unmatched	Device not in classifier patterns	Both	Low	Partially — expand keyword list


12. Supporting Documents
The following documents accompany this guide and provide additional context for VXXXXXs.
Document	Purpose	What to Use It For
IDP_Handoff_Guide_VXXXXXs_2026-05-28.docx (this document)	Extraction rules, edge cases, and integration reference	Primary reference for Rules Engine implementation
IDP_Engineering_Innovations_2026-05-28.docx	Engineering decisions, fix history, architecture lessons	Understanding WHY specific decisions were made; fix implementation details; lessons learned
Golden Dataset	Human-validated claims (Azure SQL) + bill documents (Blob Storage)	Testing and benchmarking VXXXXXs' implementation
*These documents collectively represent the full XXXXX X IDP pilot knowledge base as of May 28, 2026. For questions, contact: sogo.alonge@groupo.com


13. Glossary
Term	Definition
CTN	Customer Telephone Number — the phone number associated with a claim (stored as BillPhone in the DB)
ETF	Early Termination Fee — the fee a carrier charges when a customer leaves before their contract ends. XXXXX X reimburses this fee for qualifying ETF switch claims.
Val_*	Validation rule fields — prefix for the 6 eligibility rules (Val_CopyOfBill, Val_CTNMatch, etc.)
NR	Needs Review — claim cannot be auto-decided; routed to human reviewer
All-in accuracy	AutoCorrect / Total claims. NR claims count as misses. Production-representative metric.
Decidable accuracy	AutoCorrect / (Total − NR). Measures pipeline quality only on claims it could decide.
AutoCorrect	Claim where AI decision matches human label (Passed or Partial_High — off by ≤ 1 rule)
AutoWrong	Claim where AI decision does not match human label (Partial_Low or Extraction_Error — off by 2+ rules)
B1	Curated eval set — claims used during prompt tuning. Optimistic accuracy baseline.
B2	Fresh eval set — previously unseen claims. Production-representative accuracy baseline.
ADI	Azure Document Intelligence — Microsoft OCR service used to extract text from PDF documents
GPT-4.1	OpenAI GPT-4.1 model deployed on Azure OpenAI (claim-processor-v1 resource)
etfswitcher	Primary Azure Blob Storage container for carrier bill documents
attrewardcenter	Secondary Azure Blob Storage container — fallback for claims whose blobs are not in etfswitcher
Data_Historical_Archive	Azure SQL table containing claim records with human-validated Val_* labels (the Golden Dataset)
AI_Evaluation_Results	Azure SQL table containing AI pipeline outputs per claim and run
DocumentNames	Field in Data_Historical_Archive — semicolon-separated blob names for the claim's documents


=====================================||========================================================================
=====================================||========================================================================
IDP Pilot — Engineering Innovations & Design Decisions
Prepared by: Sogo Alonge (sogo.alonge@groupo.com)
Date: May 28, 2026
Supersedes: IDP Engineering Innovations (May 7, 2026)
Covers: Full engineering journey — run_060 baseline (78% decidable) through B2 fresh eval (TM 80.0% all-in / VZ 72.0% all-in); Go/No-Go decision May 27, 2026

This document outlines every key engineering innovation and architectural decision made across the full IDP pilot — from the initial handover files (April 2026) through the Go/No-Go decision on May 27, 2026. Innovations are grouped by era: Foundation (April), Carrier-Specific (May 1–4), Post-OI Pipeline (May 5–7), Accuracy Improvement (May 7–20), Eval Methodology & Reliability (May), and Architecture Lessons. Together these drove accuracy from 78% decidable with 13 AutoWrong to 100% decidable with 0 AutoWrong, and an honest B2 fresh-eval all-in accuracy of 80.0% (T-Mobile) and 72.0% (Verizon) accepted as the production baseline.
Accuracy Trajectory: Full Journey
Phase	Run(s)	Decidable Acc	All-In Acc	Key Innovation
Baseline	run_060	78.0%	78.0%	No NR routing — ambiguous claims auto-fail
Foundation	run_061	95.5%	70.0%	NR routing + Pydantic + structured JSON
Foundation	run_064	98.6%	70.0%	100 claims; multi-pass date extraction
Carrier-Specific	run_076 (VZ)	100.0%	75.0%	Fix #1–#4; first VZ 100% decidable run
Carrier-Specific	run_077 (TM)	97.4%	75.5%	Fix #3 FourMonths phrasing; NR 15→11
Post-OI	run_092 (TM)	100.0%	83.3%	All OI fixes; 0 AutoWrong ✅
Post-OI	run_091 (VZ)	100.0%	73.9%	All OI fixes; 0 AutoWrong ✅
Acc. Improvement	run_109 (VZ)	100.0%	78.3%	Fix J vision retry; +4.3pp VZ
Acc. Improvement	run_117 (VZ)	100.0%	89.1%	Fix K buyout regex; +4.3pp VZ
Acc. Improvement	run_123 (VZ)	100.0%	93.5%	Fix M activity strip; +4.4pp VZ
Acc. Improvement	run_128 (TM)	97.7%	87.5%	Fix N fallback container; +8.3pp TM
Acc. Improvement	run_131 (TM)	93.6%	91.7%	Fix P CTN hint; best TM run (volatile)
B1 Curated Eval	run_133+139 (TM)	100%	88.8%	98 curated claims; above 88% floor ✓
B1 Curated Eval	run_137+140 (VZ)	98.4%	83.3%	96 curated claims; Fix Q VZ JPEG buyout
B2 Fresh Eval	run_141+142 (TM)	94.1%	80.0%	100 unseen claims; honest production baseline
B2 Fresh Eval	run_143+144 (VZ)	92.3%	72.0%	100 unseen claims; accepted as handoff baseline

Decidable accuracy = AutoCorrect / (Total − NR). All-in accuracy = AutoCorrect / Total. B2 gap vs B1 (8–11pp) is expected — prompts were tuned on B1 claims. Cory confirmed No-Go on refinement on 2026-05-27: B2 is the accepted production baseline.
 
All Innovations at a Glance
#	Innovation	Era	Accuracy Impact	Production Relevance
1	Human-in-the-Loop NR Routing	Foundation	78% → 95.5% decidable — single largest driver	Critical — separates doc quality issues from AI errors
2	Pydantic Extraction Validation	Foundation	Eliminated silent field-format failures	Critical — foundational for any prod AI pipeline
3	Structured JSON Output Enforcement	Foundation	Eliminated unparseable AI responses	Critical — consistent extraction contract
4	Multi-Pass Bill Date Extraction	Foundation	Recovered 2 baseline failures	Medium — reduces NR on degraded date docs
5	Completeness-Based Device Merging	Foundation	Fixed VZ split-row + multi-doc issues	High — VZ = 60% of claim volume
6	Carrier-Specific Prompt Engineering	Foundation	Unlocked carrier-level edge case handling	High — required for every new carrier
7	Prompt Versioning in SQL	Foundation	Hot-swap prompts without code deploy	High — routine ongoing tuning
8	TypedDict Type Layer	Foundation	Dev-time error prevention; easier onboarding	High — VXXXXXs onboarding + extensibility
9	Direct Azure SQL + Blob Integration	Foundation	Removed manual data prep from workflow	Critical — prerequisite for production
10	Extraction_Error → NR (Fix #1)	Carrier	VZ decidable 89.7% → 100% (4 auto-fails fixed)	Critical — valid bill must never auto-fail
11	Carrier Filter Normalization (Fix #2)	Carrier	Eliminated silent wrong-carrier runs	High — run_073 silently ran 2 claims
12	FourMonths Phrasing Variants (Fix #3)	Carrier	TM NR 15→11; Comcast decidable 80%→90%	High — covers Spanish + all X-of-Y variants
13	Store Receipt Rejection (Fix #4)	Carrier	Eliminated CopyOfBill over-acceptance	Medium — specific VZ bill type
14	Per-Claim DB Commits (Fix A)	Post-OI	Crash-safe — no data loss on process death	Critical — run_084 lost 48 claims without this
15	Timeout NULL-Safe Coercion (Fix B)	Post-OI	Prevents infinite hang on NULL config	High — silent reliability bug
16	Final Charge Auto-Pass FourMonths (Fix C)	Post-OI	Cancelled-line switcher claims → Passed	High — common T-Mobile switcher pattern
17	Buyout (X-Y) Pipeline Parser (Fix D)	Post-OI	NR → AutoCorrect on buyout-format claims	High — common VZ switcher format
18	Final Charge + Balance → 4 Months (Fix E)	Post-OI	1195460 + 1196974 Partial_High → Passed	High — covers cancelled-line bills
19	Markdown Scanner 80-Char Window	Post-OI	4 VZ AutoWrong → NR; 0 AutoWrong restored	High — multi-line VZ bill false positives
20	Ineligible Class → NR Not Auto-Fail	Post-OI	Unknown device routes safely to NR	Critical — no valid claim auto-fails on ambiguity
21	Vision 429 Retry + Throttle (Fix J)	Acc. Improve	VZ +4.3pp 73.9%→78.3% (run_109)	Critical — resolved all batch rate-limit failures
22	Account-Level Buyout Regex (Fix K)	Acc. Improve	VZ +4.3pp 78.3%→89.1% (run_117)	High — VZ account-level billing pattern
23	Doc Intel 429 Retry (Fix L)	Acc. Improve	Resilience measure; no direct acc gain	Medium — prevents DI timeout cascades
24	Activity Log Section Strip (Fix M)	Acc. Improve	VZ +4.4pp 89.1%→93.5%; 99K→13K chars (run_123)	Critical — prevents GPT context overflow on large PDFs
25	attrewardcenter Fallback Container (Fix N)	Acc. Improve	TM +8.3pp 79.2%→87.5% (run_128)	Critical — blobs in wrong container → NR without this
26	EXIF Rotation + 2048px Resize (Fix O)	Acc. Improve	Fixed sideways JPEGs + Zscaler truncation	High — phone-photographed bills common in TM
27	CTN Hint Injection (Fix P)	Acc. Improve	TM +4.2pp 85.4%→89.6–91.7% (runs 131–132)	High — dense family bills need target CTN hint
28	VZ JPEG Buyout Path (Fix Q)	Acc. Improve	VZ +5.6pp 81.7%→87.3% (run_137)	High — Fix K was PDF-only; extended to vision path
29	NOT EXISTS Fresh Batch Filter	Methodology	Enables true fresh eval without re-running claims	Critical — prevents silent skip of new claims
30	B1 vs B2 Eval Methodology	Methodology	Establishes honest production baseline separate from tuned set	High — prevents over-optimistic accuracy reporting
31	Stale Run Management Pattern	Methodology	Clean run registry; accurate run tracking	Medium — operational hygiene

 
Part 1: Foundation Innovations (April 2026)
1. Human-in-the-Loop Needs Review Routing
File: production/rules/validation_rules.py
The original pipeline had two outcomes: pass or fail. There was no concept of a claim being undecidable due to document quality rather than AI error. Root cause analysis of the 13 baseline failures showed that 11 were missing-data situations, not AI mistakes, that should never auto-fail. A five-condition routing layer was designed to send these cases to human review. This was the single largest driver of accuracy improvement: 78% → 95.5% decidable in one step.
The critical operational insight: 'AI got it wrong' and 'the document did not contain the required information' are fundamentally different outcomes. Conflating them inflates error rates and penalizes valid claims. Separating them gives accurate AI quality metrics (decidable accuracy) AND production throughput (all-in accuracy); both essential for business decisions.
NR Trigger	What It Catches	Why Not Auto-Fail
Bill date not parseable	Degraded doc; unusual date label	Human can confirm bill is valid even if date is unreadable
CTN not found in extracted devices	Summary page; blobs missing; image quality	AI extraction miss ≠ claim ineligible
CTN matched, no installment detail	Summary page; account-only view	Detail may exist on another page
Progress < 4 months AND no balance	Partial extraction; borderline doc	Missing balance ≠ no balance
Device type unknown + CTN unmatched	Device not in classifier patterns	Unknown ≠ ineligible

83% of NR cases in early runs were summary-page submissions, a claim submission quality pattern, not an AI limitation.
2. Pydantic Extraction Validation Layer
File: production/models/openai_layout.py
The original pipeline passed raw AI text into the rules engine with no validation. A Pydantic model layer enforces field-level contracts on every extraction before it reaches business logic — normalizing phone numbers, currency, date strings, and stripping whitespace. This eliminated an entire class of silent failures where the AI output was technically correct but formatted in a way the rules engine could not interpret.
Validator	What It Prevents
normalize_phone()	Partial CTNs (last 4 digits only) causing false CTN non-match
normalize_balance()	Currency symbols, 'N/A', 'null', 'unknown' breaking balance comparisons
normalize_progress()	Variant phrases ('Month 24 of 24', 'final month', 'Final charge') being missed
normalize_bill_date()	6+ date format variants (Jan 5 2026 / 01/05/2026 / 2026-01-05) parsed inconsistently
deduplicate_devices()	Verizon split-row DPA entries creating phantom duplicate devices
str_strip_whitespace	Leading/trailing spaces causing all string comparisons to fail silently
UUID/filename rejection	GPT occasionally returns document filenames as field values

3. Structured JSON Output Enforcement
File: production/models/openai_layout.py
Extraction was migrated from freeform text to response_format: json_schema with the Pydantic schema as the enforced output contract. Every extraction returns a validated, typed object or raises a recoverable error — eliminating unparseable string responses entirely. Combined with the Pydantic layer, the rules engine always receives clean, typed data. _make_strict_schema() adds additionalProperties=false and marks all fields required i.e. GPT cannot return keys not in schema or hallucinate structure.
4. Multi-Pass Bill Date Extraction
File: production/models/openai_layout.py
When primary extraction returns no bill date, a targeted second API call runs against the first 3,000 characters of the document markdown with a focused date-only prompt (100 max tokens). Prompt chaining pattern: first pass handles everything; second pass handles only the failed field. Resolved 2 baseline failures at minimal additional cost.
5. Completeness-Based Device Merging
File: production/pipeline/aggregation.py
Verizon bills frequently split a single device's installment data across two table rows. Multi-document claims can have the same CTN appear in both a summary page and a detail page with different field sets. A scoring-based merge evaluates field completeness across all documents and retains the most complete device record per CTN. Field weighting: phone_number > installment_balance > installment_progress > device_model. account_level_buyouts are preserved through the merge (required for Fix K to work).
6. Carrier-Specific Prompt Engineering
Files: Config_Prompts SQL table (OpenAI_Extraction_TMobile, OpenAI_Extraction_Verizon, etc.)
Deep analysis of real carrier bill documents identified carrier-specific edge cases invisible without running actual claims: EIP listed under Monthly Charges, split DPA rows in Verizon tables, paid-off balances as $0.00, ambiguous device type labels. The methodology is to run real claims, inspect failures, add explicit prompt guidance. This is repeatable for every new carrier.
Carrier	Prompt	Key Additions
T-Mobile	v1.3.3	EIP, Removed lines, Final charge, HANDSETS section guidance, CTN hint slot, FourMonths phrasings, attrewardcenter blobs
Verizon	v1.3.1	Buyout (X-Y), 5G Core, Device Payment Agreement (DPA), store receipt rejection, account-level buyout extraction (JPEG path)
Spectrum	v1.2.0	FourMonths INSTALLMENT PROGRESS section; matches T-Mobile/Verizon pattern
Comcast	v1.2.0	FourMonths phrasing; CopyOfBill (structural NR issue unresolved)

Prompt regression lesson (v1.3.2): Adding a REMOVED-LINE section to TM prompt caused 4 regressions by narrowing search scope. Always test against full eval set before marking stable. Reverted as v1.3.3.
7. Prompt Versioning in Azure SQL
Files: Config_Prompts SQL table, push_prompts_*.py scripts
All prompts stored in Config_Prompts with Version column (vMAJOR.MINOR.PATCH). Prompts load at runtime and carrier updates require no code deployment. Every eval run result is tied to the prompt version active at run time. A/B testing: update DB, run eval, compare.
8. TypedDict Type Layer
File: production/pipeline/types.py
Untyped dictionaries replaced with TypedDict boundaries at every pipeline stage — model runners, aggregation, validation, reporting. Enables IDE type checking, catches integration errors at development time, and makes the codebase easier for VXXXXXs to onboard, extend, and maintain.
9. Direct Azure SQL and Blob Storage Integration
Files: production/services/database.py, production/services/blob_storage.py
CSV exports and manual document downloads replaced with direct Azure SQL reads and DefaultAzureCredential-based Blob Storage access. Pipeline operates entirely against live infrastructure without manual data preparation. A prerequisite for any production deployment.
 
Part 2 — Carrier-Specific Fixes (May 1–4, 2026)
10. Extraction_Error → Needs Review (Fix #1)
File: production/pipeline/batch.py
When OpenAI returns no content, the original pipeline auto-failed the claim as Submitted Incomplete. Manual inspection of 4 Verizon claims (run_075) confirmed all 4 were valid readable bills — the AI couldn't process them but a human reviewer could. Changed so Extraction_Error routes to Needs_Review. Impact: Verizon decidable accuracy jumped from 89.7% to 100.0% in run_076.
11. Carrier Filter Normalization (Fix #2)
File: production/services/database.py, load_claims()
Run_073 silently processed only 2 claims instead of 50 because 'TMobile' did not match 'T-Mobile' in the WHERE clause. Fix strips hyphens and spaces and lowercases both the argument and the DB column before matching. 'TMobile', 'T-Mobile', and 't mobile' all match. Discovered after the fact by cross-checking run record counts — a silent failure that produced misleading accuracy numbers for that run.
12. FourMonths Phrasing Variants (Fix #3 — All 4 Carriers)
Files: Config_Prompts SQL table — all 4 carrier prompts
The AI was returning only the payment number ('4') without the total ('of 24'), causing parse_installment_progress() to return None → NR. Added INSTALLMENT PROGRESS section to all 4 prompts requiring 'X of Y' format, explicitly listing: 'Month X of Y', 'Payment X of Y', 'Installment X of Y', 'X/Y', 'Cuota X de Y' (Spanish). The prompt also bans returning empty when a payment number is visible. Spanish phrasing added after claim 1192122 (Spanish bill).
Impact: TM NR 15→11 (run_077). Comcast decidable 80%→90% (run_079).
13. Store Receipt Rejection (Fix #4 — Verizon)
File: Config_Prompts SQL table — Verizon v1.2.0
Manual inspection of claim 1195475 found a Verizon store purchase receipt. The AI accepted CopyOfBill=Complete because it was a Verizon document with a date. Fix #4 added a COPY OF BILL VALIDATION section explicitly rejecting documents with 'Receipt of transaction' header, store address, barcode, and 'Your Verizon receipt; generated on...' footer.
 
Part 3 — Post-OI Pipeline Fixes (May 5–7, 2026)
14. Per-Claim DB Commits — Crash Safety by Design (Fix A)
File: production/pipeline/batch.py
Run_084 failed after 6+ hours: the process was killed with 0 results committed. Root cause: batch.py accumulated all results in memory and called append_evaluation_results() once at the end. Process death lost all work. Fix: call append_evaluation_results([rec], run_id) immediately after each claim. Any future process death preserves all previously committed claims. Standard pattern for long-running batch jobs — write-through, not write-at-end.
15. Timeout NULL-Safe Coercion (Fix B)
File: production/models/openai_layout.py
get_param('OpenAIExtractionTimeoutSeconds', 120) could return None if the DB row had a NULL. requests.post(timeout=None) disables the timeout — enabling infinite hangs. Fix: int(get_param(...) or 120) coerces None to the default. A silent reliability bug that could cause indefinite pipeline hangs.
16. Final Charge Auto-Pass FourMonths (Fix C — Issue 2b)
Files: production/rules/validation_rules.py, production/rules/validation_helpers.py
T-Mobile switcher bills mark cancelled lines with 'Final charge (line cancelled)' text instead of a standard 'Payment X of 24' counter. Business decision (Ryan Nelson, May 6): remaining EIP balance on a cancelled line proves active installment contract — treat as 4+ months. Implementation: if 'Final charge' AND 'cancelled' in installment_progress AND balance > 0 → auto-pass FourMonths regardless of payment number.
17. Verizon Buyout Notation (X-Y) Pipeline Parser (Fix D)
File: production/rules/validation_helpers.py
Verizon switcher bills use 'Device Payment Buyout Charge (X-Y) Agreement' format. (X-Y) means payments X through Y are being bought out — so X payments were already made. parse_installment_progress() now recognizes the (X-Y) pattern via regex, returning (X, Y). Ryan Nelson confirmed (May 6): use X directly, not X-1. This is a pipeline-level fix because GPT-4.1's trained behavior consistently failed to extract the buyout as installment balance even with explicit prompt instructions — illustrating when prompt changes are insufficient.
18. Final Charge + Balance → FourMonths Pass (Fix E)
Files: production/rules/validation_helpers.py, production/rules/validation_rules.py
parse_installment_progress() accepts an optional balance_str parameter. If 'Final charge (line cancelled)' detected and balance_str is non-zero: returns (4, 24). If Final charge detected but no balance: returns (None, None) → NR. Claims 1195460 and 1196974 converted from Partial_High → Passed in run_092.
19. Markdown Scanner — 80-Character Neighbor CTN Window
File: production/pipeline/batch.py, _classify_ctn_from_markdown()
The pipeline scans raw Document Intelligence markdown for the claim CTN and checks the surrounding text for ineligible device keywords. Original context window: 500 characters — wide enough to pick up keywords from adjacent CTN rows on multi-line Verizon bills. Root cause (run_090): 4 Verizon claims AutoWrong because the scanner found an ineligible device keyword from a neighboring CTN's row. Fix: reduced to 80-character window. Additional guard: skip if another CTN appears within 80 chars — the keyword belongs to that other row, not the claim CTN.
Impact: 4 Verizon AutoWrong → NR in run_091. Combined with #20, restored VZ to 0 AutoWrong.
20. Ineligible Device Class → NR Not Auto-Fail
File: production/rules/validation_rules.py, evaluate_eligibility()
evaluate_eligibility() treated device_class = 'Unknown' same as 'Tablet' or 'Wearable' — auto-failing Val_NotTabletWearable. 'Unknown' means the classifier could not determine type: this should route to NR (cannot decide), not auto-fail (wrong decision). Fix: only auto-fail explicit ineligible_classes = {Tablet, Wearable, Hotspot, HomeInternet}. Unknown class → NR. Design principle: when in doubt, send to human — don't make a wrong decision.
 
Part 4 — Accuracy Improvement Innovations (May 7–20, 2026)
21. OpenAI Vision Rate-Limit Retry and Throttle (Fix J)
Files: production/models/openai_layout.py, production/services/retry.py
Batch eval runs of 48+ claims were failing silently due to HTTP 429 (Too Many Requests) from the Azure OpenAI vision endpoint. Initial diagnosis incorrectly attributed this to Zscaler SSL-inspection proxy throttling. Root cause identified as the OpenAI RPM quota. Two mitigations applied: (1) _VISION_MIN_INTERVAL_SECONDS = 3.0 — a 3-second inter-call throttle between all vision API calls; (2) with_retry() in services/retry.py retries 429 and 503 responses with delays of 15s, 30s, 60s. Impact: resolved all 429 failures. VZ claims 1197929 and 1197746 — formerly stuck as NR due to extraction timeouts — now Partial_High. VZ +4.3pp (run_109).
Lesson: always check HTTP status codes before assuming proxy/network issues. The 429 was masked inside the requests exception.
22. Account-Level Device Payment Buyout Regex (Fix K)
File: production/models/openai_layout.py, _extract_account_level_buyouts()
Verizon bills sometimes list Device Payment Buyout Charges at the account level — not linked to a specific CTN line. The AI could not extract these as per-device installment balances because there is no CTN association in the HTML table structure produced by Azure Document Intelligence.
Business decision (Ryan Nelson, May 14): account-level buyout = valid installment evidence even without per-CTN association. Implementation: _BUYOUT_RE regex scans the raw ADI markdown for HTML table patterns matching Account buyout entries. The regex uses [^$]*\$ to match across HTML cell boundaries (<td>Agreement ID</td><td>$364.86</td>) — the critical insight that made the match work where a simple \s+\$ pattern failed. Results are passed as account_level_buyouts[] through aggregation to validation_rules.py. Impact: VZ +4.3pp 78.3%→89.1% in run_117.
23. Azure Document Intelligence 429 Retry (Fix L)
File: production/services/retry.py
Azure Document Intelligence can also return HTTP 429 under sustained load. Fix L added the same retry pattern (15s/30s/60s delays) to DI calls via with_retry(). No direct accuracy gain in isolation — but a resilience measure that prevents DI timeouts from cascading into Extraction_Error NR claims under high batch load.
24. Activity Log Section Stripping (Fix M)
File: production/models/openai_layout.py, _strip_activity_sections()
A 19-page Verizon bill (claims 1197959, 1197989) was producing 99,000 characters of ADI markdown — 87% of it Talk/Data/Message activity logs (per-call records). GPT-4.1 has a 128K context window, but at 25K+ effective tokens the relevant installment data was being pushed to the edges where GPT reliability degrades.
_strip_activity_sections() scans the ADI markdown for section headers matching activity log patterns ('Talk Activity', 'Data Activity', 'Message Activity', 'Usage Details') and removes everything from that header to the next major section. Result: 99K → ~13K characters (87% reduction). Both claims passed in run_123. Impact: VZ +4.4pp 89.1%→93.5% — the largest single accuracy improvement in this phase.
This fix is applied to PDF path only (ADI markdown). JPEG/vision path does not produce activity logs.
25. attrewardcenter Fallback Container (Fix N)
File: production/services/blob_storage.py, get_document_streams_for_claim()
Some T-Mobile claims were going NR with 'no documents found' despite having valid bills. Root cause: a separate ingestion path uploads some bills to the 'attrewardcenter' Azure Blob container instead of the primary 'etfswitcher' container. The pipeline only searched etfswitcher. Fix N retries any blob not found in etfswitcher against attrewardcenter. Found blobs are registered in _blob_container_cache so generate_blob_sas_url() generates SAS URLs pointing to the correct container for GPT vision calls. Impact: Claims 1197840, 1197843, 1197849, 1197850 — all sharing the same 609KB PDF — resolved. TM +8.3pp 79.2%→87.5% in run_128 — the largest single improvement in T-Mobile.
26. EXIF Rotation and 2048px Resize (Fix O)
Files: production/services/blob_storage.py, production/models/openai_layout.py
Phone-photographed T-Mobile bills introduced two interacting problems. First: cameras capture images sideways (EXIF orientation = 6, needing 90° clockwise rotation). GPT vision receives raw JPEG bytes and does not apply EXIF orientation — reading the bill rotated 90° and missing all HANDSETS installment data. Second: full-resolution images from attrewardcenter (5712×4284px, ~3.8MB) encode to ~5MB base64 — above the Zscaler SSL-inspection proxy's payload truncation limit. GPT receives a truncated image and fails extraction.
Fix O v1: applied Pillow EXIF rotation baked into pixels before encoding. Fix O v2: added max 2048px longest-side downscale after rotation → ~350KB encoded, well within proxy limits. GPT vision tiles at 512px up to 2048px so no useful detail is lost. Non-rotated images continue to be sent as Azure Blob SAS URLs (bypassing proxy payload limits by going direct to Azure blob endpoint, not through Zscaler). Subprocess TCP context: a fresh OS-level TCP context is created per vision call to avoid Zscaler connection state accumulation across the batch.
27. CTN Hint Injection into Extraction Prompt (Fix P)
File: production/config/loader.py, get_extraction_prompt()
Dense family account bills (8–9 phone lines, 8+ handsets on compressed 48–60KB JPEG pages) caused GPT to confuse CTN digits — returning (786) 782-5993 instead of (786) 280-5993 or fabricating devices not on the bill. The core problem: GPT had no anchor telling it which specific CTN to prioritize on a page full of CTNs.
get_extraction_prompt() now appends the claim's BillPhone as a CLAIM CTN (PRIMARY TARGET) section at the end of the prompt: the specific phone number, formatted as (NXX) NXX-XXXX, with instruction to prioritize locating that CTN and extracting its device, balance, and progress precisely — while still returning all other visible devices. Impact: claims 1193564 and 1193593 → stable Partial_High and Passed respectively. TM +4.2pp 85.4%→89.6–91.7% in runs 131–132.
Fix P introduced a small regression on claim 1198040 (GPT over-focused on CTN, missed installment balance). Net gain far exceeds the regression.
28. Verizon JPEG Path Buyout Extraction (Fix Q)
File: production/models/openai_layout.py
Fix K (account-level buyout regex) was implemented in the PDF/ADI markdown path only. When the Verizon eval was expanded from 46 to 71 claims (run_134), older claims with JPEG bills showed a new NR pattern: 7 false negatives where the bill was a JPEG showing a Device Payment Buyout but Fix K never fired. Root cause: Fix K scans ADI markdown for HTML table patterns — JPEG bills go to GPT vision directly with no ADI step, so there is no markdown to scan.
Fix Q extended the account-level buyout logic to the JPEG/vision extraction path. GPT is instructed in the Verizon v1.3.1 prompt to extract account-level Device Payment Buyout Charges explicitly when per-CTN installment lines are not visible. 5 of 7 targeted false-negative NR claims → AutoCorrect in run_135. Impact: VZ +5.6pp 81.7%→87.3% in run_137.
 
Part 5 — Eval Methodology & Pipeline Reliability
29. NOT EXISTS Fresh Batch Filter in load_claims()
File: production/services/database.py, load_claims()
Running a fresh 100-claim eval (B2) with --limit 50 produced 'Processed: 50, Skipped: 0' but committed 0 new results. Root cause: load_claims() used ORDER BY ETFSwitcherOrdersID DESC and the top-50 newest claims by ID were already in AI_Evaluation_Results. The skip_processed flag operates at the model level — after blob loading — so the pipeline loaded 50 already-evaluated claims, found each already processed, skipped all 50, and wrote nothing.
Fix: in fresh batch mode (etf_ids is None), added a SQL NOT EXISTS subquery that excludes any claim already evaluated with ModelName = 'OpenAI_Layout_Hybrid'. The SQL loads only genuinely unprocessed claims, making batch size predictable and ensuring fresh eval runs never silently re-process already-evaluated claims.
This fix is critical for the B2 eval methodology — without it, 'fresh 100 claims' was actually 0 new claims silently skipped.
30. B1 vs B2 Eval Methodology — Honest Baseline Distinction

A fundamental accuracy reporting problem was identified after running the expanded eval: the original eval set (48 TM + 46 VZ claims) was used for prompt tuning. Accuracy measured against those same claims is optimistically biased — the prompts were specifically developed to pass them. This is B1 (curated).
B2 (fresh eval) runs 100 previously-unseen claims per carrier. These claims were never seen during prompt development and represent the true production distribution. The B1/B2 gap (~8–11pp) is not a regression — it is the honest measure of how much the prompts were tuned to the specific B1 claim set vs. general capability. B2 is the correct metric for Go/No-Go decisions and for reporting to stakeholders.
Eval Type	Definition	Accuracy	Use For
B1 Curated	Claims used during prompt tuning	TM 88.8% (n=98) / VZ 83.3% (n=96)	Development benchmarking; regression detection
B2 Fresh	Previously unseen claims	TM 80.0% (n=100) / VZ 72.0% (n=100)	Go/No-Go decisions; stakeholder reporting; production estimate

31. Stale Run Management
Files: AzureIDP-Pilot-Py/delete_stale_runs.py, check_runs.py
During B2 eval setup, several run entries were created in AI_Evaluation_Runs when background processes failed silently on Windows (bash background tasks produced empty output; the correct approach is PowerShell Start-Process with log file redirection). These stale entries (run_141, run_142, run_143 before the real B2 runs) caused run ID re-use confusion and wrong tracking.
delete_stale_runs.py: removes run entries from AI_Evaluation_Runs and any associated AI_Evaluation_Results rows by RunID. check_runs.py: queries current run status, claims processed, and result counts for any RunID — useful for verifying a run completed correctly before using its results in accuracy calculations.
 
Part 6 — Architecture Lessons & Design Decisions
Lesson 1: The Fix B Regression — Validate NR Triggers Before Deploying
Fix B added a NR trigger for bill date conflicts across multiple documents in a claim. Intent: catch cases where two documents had different bill dates (different billing periods). Result: 10 T-Mobile + 5 Verizon valid claims sent to NR in runs 087 and 088.
Run	Valid Claims Sent to NR	Root Cause
run_087 (T-Mobile)	10	Consecutive monthly bills have different page dates; OCR also introduces ±1-day variation
run_088 (Verizon)	5	Multi-page Verizon bills have different statement pages with slightly different dates

Fix B was removed entirely. Design rule going forward:
Before adding any new NR trigger: identify at least 5 known-good claims that the trigger should NOT fire on, and verify explicitly. The cost of a wrongly-fired trigger (valid claims sent to human review) is higher than the cost of a missing trigger. AutoWrong errors are the primary accuracy target; NR false positives are a secondary cost that must be actively controlled.
Lesson 2: The v1.3.2 Prompt Regression — Scope Matters in Prompt Changes
Prompt v1.3.2 added a REMOVED-LINE section intended to help GPT find installment data for cancelled T-Mobile lines. The section narrowed GPT's search scope to the HANDSETS section only — which broke extraction for multi-line family account bills where installment data also appears in the DETAILED CHARGES section.
Claim	v1.3.1 Result	v1.3.2 Result	Root Cause
1193564	Partial_High	NR	HANDSETS-only scope excluded DETAILED CHARGES path
1193578	AutoCorrect	NR	Same cause
1193583	Partial	NR	Same cause
1197850	AutoCorrect	NR	Same cause

v1.3.2 reverted to v1.3.1 content as v1.3.3. Design rule:
Any prompt change that constrains search scope is high-risk for multi-line family accounts. Always run the full eval set before logging a prompt change as stable — never test on only the target claim in isolation.
Lesson 3: Prompt vs Pipeline — When to Use Each
Scenario	Better Fix	Example
AI misses a phrasing variant in well-structured text	Prompt change	FourMonths 'Month X of Y' vs 'Payment X of Y' (Fix #3)
AI correctly extracts but format is not what pipeline expects	Pipeline parse	Buyout (X-Y) notation — pipeline regex (Fix D)
AI's trained behavior overrides prompt instructions	Pipeline only	5G Core device exclusion — AI includes it regardless of prompt
Business rule definition change	Pipeline only	Final charge + balance → FourMonths pass (Fix E)
Novel document type	Prompt change	Store receipt rejection — explicit examples in prompt (Fix #4)
Large doc pushing relevant data out of context window	Pipeline + strip	Activity log sections — Fix M strips before sending to GPT
Image orientation or proxy payload limit	Pipeline only	EXIF rotation + resize — Fix O before GPT call
Blob in wrong container	Pipeline only	attrewardcenter fallback — Fix N
Structural data absence (page not submitted)	Routing change	Phase 3B multi-page routing (planned)

Lesson 4: Phase-Gated Improvement — Diagnose Before Fixing
The Phase 0 → Phase 1 → Phase 2 → Phase 3 approach was adopted after observing that prompt changes made without understanding the exact failure mode often missed the target. Phase 0 blob inspection categorizes NR claims into: fixable-via-prompt, fixable-via-pipeline, test-data-error, or structural. Only after categorization should any code change be made. Each fix has a specific claim ID and confirmed trigger reason behind it.
Lesson 5: The Business Rule Clarification Loop
FourMonths was the most ambiguous rule — requiring 4 months of 'service' but the bill only shows an EIP counter. Three business decisions were needed:
Scenario	Ambiguity	Resolution	Authority
'Payment 2 of 24'	EIP count or service tenure?	EIP count — AI correct; test data corrected	Ryan Nelson, May 6
'Final charge (cancelled)'	How many months paid? Cannot determine.	Pass if balance > 0 — proves active EIP	Ryan Nelson, May 7
Buyout format (X-Y)	X payments made or X-1?	Use X directly	Ryan Nelson, May 6
Account-level buyout (VZ)	Valid installment evidence without per-CTN link?	YES — valid evidence	Ryan Nelson, May 14

Key process insight: ambiguous rules should trigger an escalation document with specific claim examples, not a best-guess prompt change. Escalation (May 6) produced decisions within 24 hours and resolved 4 open issues cleanly.
Lesson 6: SAS URL vs Base64 — Zscaler Proxy Bypass Strategy
The corporate Zscaler SSL-inspection proxy creates two distinct payload problems for GPT vision calls. Problem 1: large base64-encoded images (~5MB) hit the proxy's silent truncation limit — GPT receives a partial image and fails extraction. Problem 2: repeated Azure AD User Delegation Key (UDK) fetches via Zscaler cause rate-limiting after ~40 requests, making SAS URL generation return None silently.
Two-track strategy implemented:
•	Non-rotated images: sent as Azure Blob SAS URLs. The SAS URL goes directly to the Azure blob endpoint, bypassing Zscaler payload limits entirely. UDK is cached at module level to avoid repeated Azure AD round-trips.
•	Rotation-corrected images: EXIF correction bakes rotation into pixels. The corrected image is not stored in Azure — so a SAS URL would point to the unrotated original. These are sent as base64 (post-resize to 2048px max, ~350KB — well under proxy limits).
•	Subprocess TCP context: a fresh OS-level subprocess context per vision call avoids Zscaler connection state accumulation across long batches.
 
Part 7 — The Go/No-Go Decision (May 27, 2026)
On May 27, 2026, Cory Shounick confirmed the Go/No-Go outcome: No-Go on further pipeline refinement. The current state is accepted as good enough for the business use case and for VXXXXXs to work with. No further prompt engineering, pipeline fixes, or accuracy improvements are planned.
What Was Accepted as the Production Baseline
Eval	Carrier	n	All-In Acc	Decidable Acc	NR Rate	Decision
B1 Curated	T-Mobile	98	88.8%	100.0%	11.2%	✅ Accepted — above 88% floor
B1 Curated	Verizon	96	83.3%	100.0%	13.5%	✅ Accepted — good enough
B2 Fresh	T-Mobile	100	80.0%	94.1%	15.0%	✅ Accepted — honest production baseline
B2 Fresh	Verizon	100	72.0%	92.3%	22.0%	✅ Accepted — honest production baseline

Why This Decision Was the Right Call
The engineering team applied 16 targeted fixes (Fixes A through Q plus 12 foundation fixes) across 7 weeks of development. The diminishing returns curve was evident: early fixes each delivered 4–8pp all-in accuracy gains; later fixes delivered 1–4pp with increasing complexity and risk of regression (as the v1.3.2 regression demonstrated). The remaining NR gap is largely structural — summary-page submissions and document quality issues that cannot be resolved by prompt engineering alone. These require multi-page routing (Phase 3B) or changes to how customers submit documents — neither of which is the pipeline's responsibility.
The business decision was to ship the pipeline at its current capability and let VXXXXXs integration experience reveal the next most impactful improvements, rather than continuing to optimize in isolation against a fixed eval set.
What Was Handed Over to VXXXXXs
Asset	Description	Status
T-Mobile Prompt v1.3.3	GPT-4.1 extraction prompt tuned for TM bills	✅ Ready
Verizon Prompt v1.3.1	GPT-4.1 extraction prompt tuned for VZ bills	✅ Ready
Extraction Rules & Edge Cases	IDP_Handoff_Guide_VXXXXXs_2026-05-28.docx (31 items)	✅ Ready
This document	IDP_Engineering_Innovations_2026-05-28.docx	✅ Ready
Living Documentation	IDP_Living_Documentation_2026-05-28.docx	✅ Ready
Golden Dataset	Data_Historical_Archive + etfswitcher/attrewardcenter	⏳ Access pending Cory/security approval
Source code	feature/idp-pipeline-v2 branch	⏳ GitHub access pending IT


This document covers the full engineering journey from run_060 (78% decidable, 13 AutoWrong) through the B2 fresh eval (TM 80.0% / VZ 72.0% all-in, 0 AutoWrong on decidable claims) and the Go/No-Go decision of May 27, 2026. 31 innovations documented across 7 parts. Contact: sogo.alonge@groupo.com

=====================================||========================================================================
=====================================||========================================================================
=====================================||========================================================================
=====================================||========================================================================
=====================================||========================================================================
=====================================||========================================================================
=====================================||========================================================================


=====================================||========================================================================
### AKS cluster resource

resource "azurerm_kubernetes_cluster" "aks" {
  name                              = azurecaf_name.aks.result
  location                          = local.location
  resource_group_name               = local.resource_group_name
  role_based_access_control_enabled = try(var.settings.role_based_access_control_enabled, null)

  default_node_pool {
    zones                         = try(var.settings.default_node_pool.zones, var.settings.default_node_pool.availability_zones, null)
    enable_auto_scaling           = try(var.settings.default_node_pool.enable_auto_scaling, false)
    enable_host_encryption        = try(var.settings.default_node_pool.enable_host_encryption, false)
    enable_node_public_ip         = try(var.settings.default_node_pool.enable_node_public_ip, false)
    fips_enabled                  = try(var.settings.default_node_pool.fips_enabled, null)
    kubelet_disk_type             = try(var.settings.default_node_pool.kubelet_disk_type, null)
    max_count                     = try(var.settings.default_node_pool.max_count, null)
    max_pods                      = try(var.settings.default_node_pool.max_pods, 30)
    min_count                     = try(var.settings.default_node_pool.min_count, null)
    name                          = var.settings.default_node_pool.name //azurecaf_name.default_node_pool.result
    node_count                    = try(var.settings.default_node_pool.node_count, 1)
    node_labels                   = try(var.settings.default_node_pool.node_labels, null)
    node_public_ip_prefix_id      = try(var.settings.default_node_pool.node_public_ip_prefix_id, null)
    only_critical_addons_enabled  = try(var.settings.default_node_pool.only_critical_addons_enabled, false)
    orchestrator_version          = try(var.settings.default_node_pool.orchestrator_version, try(var.settings.kubernetes_version, null))
    os_disk_size_gb               = try(var.settings.default_node_pool.os_disk_size_gb, null)
    os_disk_type                  = try(var.settings.default_node_pool.os_disk_type, null)
    os_sku                        = try(var.settings.default_node_pool.os_sku, null)
    tags                          = merge(try(var.settings.default_node_pool.tags, {}), local.tags)
    temporary_name_for_rotation   = try(var.settings.default_node_pool.temporary_name_for_rotation, null)
    type                          = try(var.settings.default_node_pool.type, "VirtualMachineScaleSets")
    ultra_ssd_enabled             = try(var.settings.default_node_pool.ultra_ssd_enabled, false)
    vm_size                       = var.settings.default_node_pool.vm_size
    capacity_reservation_group_id = try(var.settings.capacity_reservation_group_id, null)
    custom_ca_trust_enabled       = try(var.settings.custom_ca_trust_enabled, null)
    host_group_id                 = try(var.settings.host_group_id, null)

    pod_subnet_id  = can(var.settings.default_node_pool.pod_subnet_key) == false || can(var.settings.default_node_pool.pod_subnet.key) == false || can(var.settings.default_node_pool.pod_subnet_id) || can(var.settings.default_node_pool.pod_subnet.resource_id) ? try(var.settings.default_node_pool.pod_subnet_id, var.settings.default_node_pool.pod_subnet.resource_id, null) : var.vnets[try(var.settings.lz_key, var.client_config.landingzone_key)][var.settings.vnet_key].subnets[try(var.settings.default_node_pool.pod_subnet_key, var.settings.default_node_pool.pod_subnet.key)].id
    vnet_subnet_id = can(var.settings.default_node_pool.vnet_subnet_id) || can(var.settings.default_node_pool.subnet.resource_id) ? try(var.settings.default_node_pool.vnet_subnet_id, var.settings.default_node_pool.subnet.resource_id) : var.vnets[try(var.settings.vnet.lz_key, var.settings.lz_key, var.client_config.landingzone_key)][try(var.settings.vnet.key, var.settings.vnet_key)].subnets[try(var.settings.default_node_pool.subnet_key, var.settings.default_node_pool.subnet.key)].id

    dynamic "upgrade_settings" {
      for_each = try(var.settings.default_node_pool.upgrade_settings, null) == null ? [] : [1]
      content {
        max_surge = upgrade_settings.value.max_surge
      }
    }

    dynamic "kubelet_config" {
      for_each = try(var.settings.default_node_pool.kubelet_config, null) == null ? [] : [1]
      content {
        allowed_unsafe_sysctls    = try(kubelet_config.value.allowed_unsafe_sysctls, null)
        container_log_max_line    = try(kubelet_config.value.container_log_max_line, null)
        container_log_max_size_mb = try(kubelet_config.value.container_log_max_size_mb, null)
        cpu_cfs_quota_enabled     = try(kubelet_config.value.cpu_cfs_quota_enabled, null)
        cpu_cfs_quota_period      = try(kubelet_config.value.cpu_cfs_quota_period, null)
        cpu_manager_policy        = try(kubelet_config.value.cpu_manager_policy, null)
        image_gc_high_threshold   = try(kubelet_config.value.image_gc_high_threshold, null)
        image_gc_low_threshold    = try(kubelet_config.value.image_gc_low_threshold, null)
        pod_max_pid               = try(kubelet_config.value.pod_max_pid, null)
        topology_manager_policy   = try(kubelet_config.value.topology_manager_policy, null)
      }
    }
    dynamic "linux_os_config" {
      for_each = try(var.settings.default_node_pool.linux_os_config, null) == null ? [] : [1]
      content {
        swap_file_size_mb = try(linux_os_config.value.allowed_unsafe_sysctls, null)
        dynamic "sysctl_config" {
          for_each = try(linux_os_config.value.sysctl_config, null) == null ? [] : [1]
          content {
            fs_aio_max_nr                      = try(sysctl_config.value.fs_aio_max_nr, null)
            fs_file_max                        = try(sysctl_config.value.fs_file_max, null)
            fs_inotify_max_user_watches        = try(sysctl_config.value.fs_inotify_max_user_watches, null)
            fs_nr_open                         = try(sysctl_config.value.fs_nr_open, null)
            kernel_threads_max                 = try(sysctl_config.value.kernel_threads_max, null)
            net_core_netdev_max_backlog        = try(sysctl_config.value.net_core_netdev_max_backlog, null)
            net_core_optmem_max                = try(sysctl_config.value.net_core_optmem_max, null)
            net_core_rmem_default              = try(sysctl_config.value.net_core_rmem_default, null)
            net_core_rmem_max                  = try(sysctl_config.value.net_core_rmem_max, null)
            net_core_somaxconn                 = try(sysctl_config.value.net_core_somaxconn, null)
            net_core_wmem_default              = try(sysctl_config.value.net_core_wmem_default, null)
            net_core_wmem_max                  = try(sysctl_config.value.net_core_wmem_max, null)
            net_ipv4_ip_local_port_range_max   = try(sysctl_config.value.net_ipv4_ip_local_port_range_max, null)
            net_ipv4_ip_local_port_range_min   = try(sysctl_config.value.net_ipv4_ip_local_port_range_min, null)
            net_ipv4_neigh_default_gc_thresh1  = try(sysctl_config.value.net_ipv4_neigh_default_gc_thresh1, null)
            net_ipv4_neigh_default_gc_thresh2  = try(sysctl_config.value.net_ipv4_neigh_default_gc_thresh2, null)
            net_ipv4_neigh_default_gc_thresh3  = try(sysctl_config.value.net_ipv4_neigh_default_gc_thresh3, null)
            net_ipv4_tcp_fin_timeout           = try(sysctl_config.value.net_ipv4_tcp_fin_timeout, null)
            net_ipv4_tcp_keepalive_intvl       = try(sysctl_config.value.net_ipv4_tcp_keepalive_intvl, null)
            net_ipv4_tcp_keepalive_probes      = try(sysctl_config.value.net_ipv4_tcp_keepalive_probes, null)
            net_ipv4_tcp_keepalive_time        = try(sysctl_config.value.net_ipv4_tcp_keepalive_time, null)
            net_ipv4_tcp_max_syn_backlog       = try(sysctl_config.value.net_ipv4_tcp_max_syn_backlog, null)
            net_ipv4_tcp_max_tw_buckets        = try(sysctl_config.value.net_ipv4_tcp_max_tw_buckets, null)
            net_ipv4_tcp_tw_reuse              = try(sysctl_config.value.net_ipv4_tcp_tw_reuse, null)
            net_netfilter_nf_conntrack_buckets = try(sysctl_config.value.net_netfilter_nf_conntrack_buckets, null)
            net_netfilter_nf_conntrack_max     = try(sysctl_config.value.net_netfilter_nf_conntrack_max, null)
            vm_max_map_count                   = try(sysctl_config.value.vm_max_map_count, null)
            vm_swappiness                      = try(sysctl_config.value.vm_swappiness, null)
            vm_vfs_cache_pressure              = try(sysctl_config.value.vm_vfs_cache_pressure, null)
          }
        }
        transparent_huge_page_defrag  = try(linux_os_config.value.transparent_huge_page_defrag, null)
        transparent_huge_page_enabled = try(linux_os_config.value.transparent_huge_page_enabled, null)
      }
    }
  }

  dns_prefix                 = try(var.settings.dns_prefix, try(var.settings.dns_prefix_private_cluster, random_string.prefix.result))
  dns_prefix_private_cluster = try(var.settings.dns_prefix_private_cluster, null)
  automatic_channel_upgrade  = try(var.settings.automatic_channel_upgrade, null)

  dynamic "key_management_service" {
    for_each = try(var.settings.key_management_service[*], {})
    content {
      key_vault_key_id         = key_management_service.value.key_vault_key_id
      key_vault_network_access = try(key_management_service.value.key_vault_network_access, null)
      #secret_rotation_enabled  = try(key_management_service.value.secret_rotation_enabled, null) # legacy?
      #secret_rotation_interval = try(key_management_service.value.secret_rotation_enabled, null) # legacy?
    }
  }

  dynamic "aci_connector_linux" {
    for_each = try(var.settings.addon_profile.aci_connector_linux[*], var.settings.aci_connector_linux[*], {})

    content {
      subnet_name = aci_connector_linux.value.subnet_name
    }
  }

  azure_policy_enabled             = can(var.settings.addon_profile.azure_policy) || can(var.settings.azure_policy_enabled) == false ? try(var.settings.addon_profile.azure_policy.0.enabled, null) : var.settings.azure_policy_enabled
  http_application_routing_enabled = can(var.settings.addon_profile.http_application_routing) || can(var.settings.http_application_routing_enabled) == false ? try(var.settings.addon_profile.http_application_routing.0.enabled, null) : var.settings.http_application_routing_enabled

  dynamic "oms_agent" {
    for_each = try(var.settings.addon_profile.oms_agent[*], var.settings.oms_agent[*], {})

    content {
      log_analytics_workspace_id      = can(oms_agent.value.log_analytics_workspace_id) ? oms_agent.value.log_analytics_workspace_id : var.diagnostics.log_analytics[oms_agent.value.log_analytics_key].id
      msi_auth_for_monitoring_enabled = try(oms_agent.value.msi_auth_for_monitoring_enabled, null)
    }
  }
  dynamic "microsoft_defender" {
    for_each = try(var.settings.microsoft_defender[*], var.settings.microsoft_defender[*], {})

    content {
      log_analytics_workspace_id = can(microsoft_defender.value.log_analytics_workspace_id) ? microsoft_defender.value.log_analytics_workspace_id : var.diagnostics.log_analytics[microsoft_defender.value.log_analytics_key].id
    }
  }

  dynamic "ingress_application_gateway" {
    for_each = can(var.settings.addon_profile.ingress_application_gateway) || can(var.settings.ingress_application_gateway) ? try([var.settings.addon_profile.ingress_application_gateway], [var.settings.ingress_application_gateway]) : []
    content {
      gateway_name = try(ingress_application_gateway.value.gateway_name, null)
      gateway_id   = try(ingress_application_gateway.value.gateway_id, try(var.application_gateway.id, null))
      subnet_cidr  = try(ingress_application_gateway.value.subnet_cidr, null)
      subnet_id    = try(ingress_application_gateway.value.subnet_id, null)
    }
  }

  dynamic "key_vault_secrets_provider" {
    for_each = can(var.settings.addon_profile.azure_keyvault_secrets_provider) || can(var.settings.key_vault_secrets_provider) ? try([var.settings.addon_profile.azure_keyvault_secrets_provider], [var.settings.key_vault_secrets_provider]) : []
    content {
      secret_rotation_enabled  = try(key_vault_secrets_provider.value.secret_rotation_enabled, null)
      secret_rotation_interval = try(key_vault_secrets_provider.value.secret_rotation_interval, null)
    }
  }

  # dynamic "addon_profile" {
  #   for_each = lookup(var.settings, "addon_profile", null) == null ? [] : [1]
  #     dynamic "kube_dashboard" {
  #       for_each = try(var.settings.addon_profile.kube_dashboard[*], [{ enabled = false }])

  #       content {
  #         enabled = kube_dashboard.value.enabled
  #       }
  #     }

  api_server_authorized_ip_ranges = try(var.settings.api_server_authorized_ip_ranges, null)

  disk_encryption_set_id = try(coalesce(
    try(var.settings.disk_encryption_set_id, ""),
    try(var.settings.disk_encryption_set.id, "")
  ), null)

  dynamic "api_server_access_profile" {
    for_each = try(var.settings.api_server_access_profile[*], {})

    content {
      authorized_ip_ranges     = try(api_server_access_profile.value.authorized_ip_ranges, null)
      subnet_id                = try(can(api_server_access_profile.value.subnet_id) ? api_server_access_profile.value.subnet_id : var.vnets[try(api_server_access_profile.value.subnet.lz_key, var.settings.vnet.lz_key, var.settings.lz_key, var.client_config.landingzone_key)][try(api_server_access_profile.value.subnet.vnet_key, var.settings.vnet_key)].subnets[try(api_server_access_profile.value.subnet.key, var.settings.subnet_key)].id, null)
      vnet_integration_enabled = try(api_server_access_profile.value.vnet_integration_enabled, false)
    }
  }

  dynamic "auto_scaler_profile" {
    for_each = try(var.settings.auto_scaler_profile[*], {})

    content {
      balance_similar_node_groups      = try(auto_scaler_profile.value.balance_similar_node_groups, null)
      expander                         = try(auto_scaler_profile.value.expander, null)
      max_graceful_termination_sec     = try(auto_scaler_profile.value.max_graceful_termination_sec, null)
      max_node_provisioning_time       = try(auto_scaler_profile.value.max_node_provisioning_time, null)
      max_unready_nodes                = try(auto_scaler_profile.value.max_unready_nodes, null)
      max_unready_percentage           = try(auto_scaler_profile.value.max_unready_percentage, null)
      new_pod_scale_up_delay           = try(auto_scaler_profile.value.new_pod_scale_up_delay, null)
      scale_down_delay_after_add       = try(auto_scaler_profile.value.scale_down_delay_after_add, null)
      scale_down_delay_after_delete    = try(auto_scaler_profile.value.scale_down_delay_after_delete, null)
      scale_down_delay_after_failure   = try(auto_scaler_profile.value.scale_down_delay_after_failure, null)
      scan_interval                    = try(auto_scaler_profile.value.scan_interval, null)
      scale_down_unneeded              = try(auto_scaler_profile.value.scale_down_unneeded, null)
      scale_down_unready               = try(auto_scaler_profile.value.scale_down_unready, null)
      scale_down_utilization_threshold = try(auto_scaler_profile.value.scale_down_utilization_threshold, null)
      empty_bulk_delete_max            = try(auto_scaler_profile.value.empty_bulk_delete_max, null)
      skip_nodes_with_local_storage    = try(auto_scaler_profile.value.skip_nodes_with_local_storage, null)
      skip_nodes_with_system_pods      = try(auto_scaler_profile.value.skip_nodes_with_system_pods, null)
    }
  }

  dynamic "identity" {
    for_each = try(var.settings.identity, null) == null ? [] : [1]

    content {
      type         = var.settings.identity.type
      identity_ids = lower(var.settings.identity.type) == "userassigned" ? can(var.settings.identity.user_assigned_identity_id) ? [var.settings.identity.user_assigned_identity_id] : [var.managed_identities[try(var.settings.identity.lz_key, var.client_config.landingzone_key)][var.settings.identity.managed_identity_key].id] : null
    }
  }



  dynamic "kubelet_identity" {
    for_each = try(var.settings.kubelet_identity, null) == null ? [] : [1]
    content {
      client_id                 = can(kubelet_identity.value.client_id) ? kubelet_identity.value.client_id : var.managed_identities[try(var.settings.kubelet_identity.lz_key, var.client_config.landingzone_key)][var.settings.kubelet_identity.managed_identity_key].client_id
      object_id                 = can(kubelet_identity.value.object_id) ? kubelet_identity.value.object_id : var.managed_identities[try(var.settings.kubelet_identity.lz_key, var.client_config.landingzone_key)][var.settings.kubelet_identity.managed_identity_key].principal_id
      user_assigned_identity_id = can(kubelet_identity.value.user_assigned_identity_id) ? kubelet_identity.value.user_assigned_identity_id : var.managed_identities[try(var.settings.kubelet_identity.lz_key, var.client_config.landingzone_key)][var.settings.kubelet_identity.managed_identity_key].id
    }
  }

  kubernetes_version = try(var.settings.kubernetes_version, null)

  dynamic "linux_profile" {
    for_each = try(var.settings.linux_profile, null) == null ? [] : [1]
    content {
      admin_username = try(var.settings.linux_profile.admin_username, null)
      dynamic "ssh_key" {
        for_each = try(var.settings.linux_profile.ssh_key, null) == null ? [] : [1]
        content {
          key_data = try(var.settings.linux_profile.ssh_key.key_data, null)
        }
      }
    }
  }

  dynamic "storage_profile" {
    for_each = try(var.settings.storage_profile[*], {})
    content {
      blob_driver_enabled         = try(storage_profile.value.blob_driver_enabled, null)
      disk_driver_enabled         = try(storage_profile.value.disk_driver_enabled, null)
      disk_driver_version         = try(storage_profile.value.disk_driver_version, null)
      file_driver_enabled         = try(storage_profile.value.file_driver_enabled, null)
      snapshot_controller_enabled = try(storage_profile.value.snapshot_controller_enabled, null)
    }
  }

  local_account_disabled = try(var.settings.local_account_disabled, false)

  dynamic "maintenance_window" {
    for_each = try(var.settings.maintenance_window, null) == null ? [] : [1]
    content {
      dynamic "allowed" {
        for_each = try(var.settings.maintenance_window.allowed, null) == null ? [] : [1]
        content {
          day   = var.settings.maintenance_window.allowed.day
          hours = var.settings.maintenance_window.allowed.hours
        }
      }
      dynamic "not_allowed" {
        for_each = try(var.settings.maintenance_window.not_allowed, null) == null ? [] : [1]
        content {
          end   = var.settings.maintenance_window.not_allowed.end
          start = var.settings.maintenance_window.not_allowed.start
        }
      }
    }
  }

  dynamic "network_profile" {
    for_each = try(var.settings.network_profile[*], {})
    content {
      network_plugin      = try(network_profile.value.network_plugin, null)
      network_mode        = try(network_profile.value.network_mode, null)
      network_policy      = try(network_profile.value.network_policy, null)
      dns_service_ip      = try(network_profile.value.dns_service_ip, null)
      docker_bridge_cidr  = try(network_profile.value.docker_bridge_cidr, null)
      outbound_type       = try(network_profile.value.outbound_type, null)
      pod_cidr            = try(network_profile.value.pod_cidr, null)
      service_cidr        = try(network_profile.value.service_cidr, null)
      service_cidrs       = try(network_profile.value.network_cidrs, null)
      load_balancer_sku   = try(network_profile.value.load_balancer_sku, null)
      ebpf_data_plane     = try(network_profile.value.ebpf_data_plane, null)
      network_plugin_mode = try(network_profile.value.network_plugin_mode, null)
      ip_versions         = try(network_profile.value.ip_versions, null)

      dynamic "load_balancer_profile" {
        for_each = try(network_profile.value.load_balancer_profile[*], {})
        content {
          idle_timeout_in_minutes     = try(load_balancer_profile.value.idle_timeout_in_minutes, null)
          managed_outbound_ip_count   = try(load_balancer_profile.value.managed_outbound_ip_count, null)
          managed_outbound_ipv6_count = try(load_balancer_profile.value.managed_outbound_ipv6_count, null)
          outbound_ip_address_ids     = try(load_balancer_profile.value.outbound_ip_address_ids, null)
          outbound_ip_prefix_ids      = try(load_balancer_profile.value.outbound_ip_prefix_ids, null)
          outbound_ports_allocated    = try(load_balancer_profile.value.outbound_ports_allocated, null)
        }
      }
    }
  }

  dynamic "service_mesh_profile" {
    for_each = try(var.settings.service_mesh_profile[*], {})
    content {
      mode                             = try(service_mesh_profile.value.mode, null)
      internal_ingress_gateway_enabled = try(service_mesh_profile.value.internal_ingress_gateway_enabled, null)
      external_ingress_gateway_enabled = try(service_mesh_profile.value.external_ingress_gateway_enabled, null)
    }
  }

  node_resource_group                 = azurecaf_name.rg_node.result
  oidc_issuer_enabled                 = try(var.settings.oidc_issuer_enabled, null)
  open_service_mesh_enabled           = try(var.settings.open_service_mesh_enabled, null)
  private_cluster_enabled             = try(var.settings.private_cluster_enabled, null)
  private_dns_zone_id                 = try(var.private_dns_zone_id, null)
  private_cluster_public_fqdn_enabled = try(var.settings.private_cluster_public_fqdn_enabled, null)
  public_network_access_enabled       = try(var.settings.public_network_access_enabled, true)

  #Enabled RBAC
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = try(var.settings.role_based_access_control[*], {})

    content {
      managed   = try(azure_active_directory_role_based_access_control.value.azure_active_directory.managed, true)
      tenant_id = try(azure_active_directory_role_based_access_control.value.azure_active_directory.tenant_id, null)

      azure_rbac_enabled     = try(azure_active_directory_role_based_access_control.value.enabled, true)
      admin_group_object_ids = try(azure_active_directory_role_based_access_control.value.azure_active_directory.admin_group_object_ids, try(var.admin_group_object_ids, null))

      client_app_id     = try(azure_active_directory_role_based_access_control.value.azure_active_directory.client_app_id, null)
      server_app_id     = try(azure_active_directory_role_based_access_control.value.azure_active_directory.server_app_id, null)
      server_app_secret = try(azure_active_directory_role_based_access_control.value.azure_active_directory.server_app_secret, null)

    }
  }

  dynamic "service_principal" {
    for_each = try(var.settings.service_principal[*], {})
    content {
      client_id     = var.settings.service_principal.client_id
      client_secret = var.settings.service_principal.client_secret
    }
  }

  sku_tier = try(var.settings.sku_tier, null)


  lifecycle {
    ignore_changes = [
      windows_profile, private_dns_zone_id
    ]
  }
  tags = merge(local.tags, lookup(var.settings, "tags", {}))

  dynamic "windows_profile" {
    for_each = try(var.settings.windows_profile[*], {})
    content {
      admin_username = var.settings.windows_profile.admin_username
      admin_password = var.settings.windows_profile.admin_password
      license        = try(var.settings.windows_profile.license, null)
      dynamic "gmsa" {
        for_each = try(windows_profile.gmsa[*], {})
        content {
          dns_server  = try(gmsa.value.dns_server, null)
          root_domain = try(gmsa.value.root_domain, null)
        }
      }
    }
  }

  dynamic "workload_autoscaler_profile" {
    for_each = try(var.settings.workload_autoscaler_profile[*], {})
    content {
      keda_enabled = try(workload_autoscaler_profile.value.keda_enabled, null)
    }
  }

  workload_identity_enabled = try(var.settings.workload_identity_enabled, null)

  dynamic "http_proxy_config" {
    for_each = try(var.settings.http_proxy_config[*], {})

    content {
      http_proxy  = try(http_proxy_config.value.http_proxy, null)
      https_proxy = try(http_proxy_config.value.https_proxy, null)
      no_proxy    = try(http_proxy_config.value.no_proxy, null)
      trusted_ca  = try(http_proxy_config.value.trusted_ca, null)
    }
  }
  dynamic "web_app_routing" {
    for_each = try(var.settings.web_app_routing[*], {})

    content {
      dns_zone_id = try(web_app_routing.value.dns_zone_id, null)
    }
  }
}

resource "random_string" "prefix" {
  length  = 10
  special = false
  upper   = false
  numeric = false
}

#
# Node pools
#

resource "azurerm_kubernetes_cluster_node_pool" "nodepools" {
  for_each = try(var.settings.node_pools, {})

  name                          = each.value.name
  kubernetes_cluster_id         = azurerm_kubernetes_cluster.aks.id
  vm_size                       = each.value.vm_size
  capacity_reservation_group_id = try(each.value.capacity_reservation_group_id, null)
  custom_ca_trust_enabled       = try(each.value.custom_ca_trust_enabled, null)
  zones                         = try(each.value.zones, each.value.availability_zones, null)
  enable_auto_scaling           = try(each.value.enable_auto_scaling, false)
  enable_host_encryption        = try(each.value.enable_host_encryption, false)
  enable_node_public_ip         = try(each.value.enable_node_public_ip, false)
  eviction_policy               = try(each.value.eviction_policy, null)
  host_group_id                 = try(each.value.host_group_id, null)

  dynamic "kubelet_config" {
    for_each = try(each.value.kubelet_config, null) == null ? [] : [1]
    content {
      allowed_unsafe_sysctls    = try(kubelet_config.value.allowed_unsafe_sysctls, null)
      container_log_max_line    = try(kubelet_config.value.container_log_max_line, null)
      container_log_max_size_mb = try(kubelet_config.value.container_log_max_size_mb, null)
      cpu_cfs_quota_enabled     = try(kubelet_config.value.cpu_cfs_quota_enabled, null)
      cpu_cfs_quota_period      = try(kubelet_config.value.cpu_cfs_quota_period, null)
      cpu_manager_policy        = try(kubelet_config.value.cpu_manager_policy, null)
      image_gc_high_threshold   = try(kubelet_config.value.image_gc_high_threshold, null)
      image_gc_low_threshold    = try(kubelet_config.value.image_gc_low_threshold, null)
      pod_max_pid               = try(kubelet_config.value.pod_max_pid, null)
      topology_manager_policy   = try(kubelet_config.value.topology_manager_policy, null)
    }
  }
  dynamic "linux_os_config" {
    for_each = try(each.value.linux_os_config, null) == null ? [] : [1]
    content {
      swap_file_size_mb = try(linux_os_config.value.allowed_unsafe_sysctls, null)
      dynamic "sysctl_config" {
        for_each = try(linux_os_config.value.sysctl_config, null) == null ? [] : [1]
        content {
          fs_aio_max_nr                      = try(sysctl_config.value.fs_aio_max_nr, null)
          fs_file_max                        = try(sysctl_config.value.fs_file_max, null)
          fs_inotify_max_user_watches        = try(sysctl_config.value.fs_inotify_max_user_watches, null)
          fs_nr_open                         = try(sysctl_config.value.fs_nr_open, null)
          kernel_threads_max                 = try(sysctl_config.value.kernel_threads_max, null)
          net_core_netdev_max_backlog        = try(sysctl_config.value.net_core_netdev_max_backlog, null)
          net_core_optmem_max                = try(sysctl_config.value.net_core_optmem_max, null)
          net_core_rmem_default              = try(sysctl_config.value.net_core_rmem_default, null)
          net_core_rmem_max                  = try(sysctl_config.value.net_core_rmem_max, null)
          net_core_somaxconn                 = try(sysctl_config.value.net_core_somaxconn, null)
          net_core_wmem_default              = try(sysctl_config.value.net_core_wmem_default, null)
          net_core_wmem_max                  = try(sysctl_config.value.net_core_wmem_max, null)
          net_ipv4_ip_local_port_range_max   = try(sysctl_config.value.net_ipv4_ip_local_port_range_max, null)
          net_ipv4_ip_local_port_range_min   = try(sysctl_config.value.net_ipv4_ip_local_port_range_min, null)
          net_ipv4_neigh_default_gc_thresh1  = try(sysctl_config.value.net_ipv4_neigh_default_gc_thresh1, null)
          net_ipv4_neigh_default_gc_thresh2  = try(sysctl_config.value.net_ipv4_neigh_default_gc_thresh2, null)
          net_ipv4_neigh_default_gc_thresh3  = try(sysctl_config.value.net_ipv4_neigh_default_gc_thresh3, null)
          net_ipv4_tcp_fin_timeout           = try(sysctl_config.value.net_ipv4_tcp_fin_timeout, null)
          net_ipv4_tcp_keepalive_intvl       = try(sysctl_config.value.net_ipv4_tcp_keepalive_intvl, null)
          net_ipv4_tcp_keepalive_probes      = try(sysctl_config.value.net_ipv4_tcp_keepalive_probes, null)
          net_ipv4_tcp_keepalive_time        = try(sysctl_config.value.net_ipv4_tcp_keepalive_time, null)
          net_ipv4_tcp_max_syn_backlog       = try(sysctl_config.value.net_ipv4_tcp_max_syn_backlog, null)
          net_ipv4_tcp_max_tw_buckets        = try(sysctl_config.value.net_ipv4_tcp_max_tw_buckets, null)
          net_ipv4_tcp_tw_reuse              = try(sysctl_config.value.net_ipv4_tcp_tw_reuse, null)
          net_netfilter_nf_conntrack_buckets = try(sysctl_config.value.net_netfilter_nf_conntrack_buckets, null)
          net_netfilter_nf_conntrack_max     = try(sysctl_config.value.net_netfilter_nf_conntrack_max, null)
          vm_max_map_count                   = try(sysctl_config.value.vm_max_map_count, null)
          vm_swappiness                      = try(sysctl_config.value.vm_swappiness, null)
          vm_vfs_cache_pressure              = try(sysctl_config.value.vm_vfs_cache_pressure, null)
        }
      }
      transparent_huge_page_defrag  = try(linux_os_config.value.transparent_huge_page_defrag, null)
      transparent_huge_page_enabled = try(linux_os_config.value.transparent_huge_page_enabled, null)
    }
  }

  fips_enabled       = try(each.value.fips_enabled, false)
  kubelet_disk_type  = try(each.value.kubelet_disk_type, null)
  max_pods           = try(each.value.max_pods, null)
  message_of_the_day = try(each.value.message_of_the_day, null)

  dynamic "node_network_profile" {
    for_each = try(var.settings.node_network_profile[*], {})

    content {
      node_public_ip_tags = try(each.value.node_network_profile, null)
    }
  }

  mode                     = try(each.value.mode, "User")
  node_labels              = try(each.value.node_labels, null)
  node_public_ip_prefix_id = try(each.value.node_public_ip_prefix_id, null)
  node_taints              = try(each.value.node_taints, null)
  orchestrator_version     = try(each.value.orchestrator_version, try(var.settings.kubernetes_version, null))
  os_disk_size_gb          = try(each.value.os_disk_size_gb, null)
  os_disk_type             = try(each.value.os_disk_type, null)
  pod_subnet_id            = can(each.value.pod_subnet_key) == false || can(each.value.pod_subnet.key) == false || can(each.value.pod_subnet_id) || can(each.value.pod_subnet.resource_id) ? try(each.value.pod_subnet_id, each.value.pod_subnet.resource_id, null) : var.vnets[try(var.settings.lz_key, var.client_config.landingzone_key)][var.settings.vnet_key].subnets[try(each.value.pod_subnet.key, each.value.pod_subnet_key)].id

  os_sku                       = try(each.value.os_sku, null)
  os_type                      = try(each.value.os_type, null)
  priority                     = try(each.value.priority, null)
  proximity_placement_group_id = try(each.value.proximity_placement_group_id, null)
  spot_max_price               = try(each.value.spot_max_price, null)
  tags                         = merge(try(var.settings.default_node_pool.tags, {}), try(each.value.tags, {}))
  scale_down_mode              = try(each.value.scale_down_mode, null)
  ultra_ssd_enabled            = try(each.value.ultra_ssd_enabled, false)
  dynamic "upgrade_settings" {
    for_each = try(each.value.upgrade_settings, null) == null ? [] : [1]
    content {
      max_surge = upgrade_settings.value.max_surge
    }
  }

  vnet_subnet_id = can(each.value.subnet.resource_id) || can(each.value.vnet_subnet_id) ? try(each.value.subnet.resource_id, each.value.vnet_subnet_id) : var.vnets[try(var.settings.vnet.lz_key, var.settings.lz_key, var.client_config.landingzone_key)][try(var.settings.vnet.key, var.settings.vnet_key)].subnets[try(each.value.subnet.key, each.value.subnet_key)].id

  dynamic "windows_profile" {
    for_each = try(each.value.windows_profile[*], {})
    content {
      outbound_nat_enabled = try(windows_profile.value.outbound_nat_enabled, null)
    }
  }

  workload_runtime = try(each.value.workload_runtime, null)

  max_count  = try(each.value.max_count, null)
  min_count  = try(each.value.min_count, null)
  node_count = try(each.value.node_count, null)
}

