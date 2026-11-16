class S {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'app_name': 'ScamShield',
      'manual_text_analysis': 'Manual Text Analysis',
      'scan_results': 'Scan Results',
      'scan_hint': 'Enter or paste message content here...',
      'scan_description_input':
          'Paste a message to check it for scam patterns before you reply or send money.',
      'clear': 'Clear',
      'scan_content': 'Scan Content',
      'privacy_note': 'Privacy Note',
      'privacy_description':
          'Messages are analyzed via the SwahBERT API (HTTPS). Only the SMS text and optional sender number are sent for classification.',
      'api_error':
          'Could not reach scam detection API. Check internet and try again.',
      'setup_welcome_title': 'Welcome to ScamShield',
      'setup_why_permissions':
          'This app helps you spot Swahili SMS scams (M-Pesa, Airtel, fake prizes). You choose what to allow.',
      'ob_feat_alerts': 'Scam alerts',
      'ob_feat_autoscan': 'Auto SMS scan',
      'ob_feat_contacts': 'Saved names',
      'setup_permissions_list':
          '• Notifications - scam alerts\n• Receive SMS - analyze new messages automatically\n• Contacts (optional) - show saved names instead of raw numbers\n• Phone - warn you about unknown callers\n\nWe do not read your full inbox. Only new incoming SMS you receive while protection is on.',
      'setup_privacy_safe':
          'Your messages stay private. History is stored only on this phone. You can use manual scan without SMS access.',
      'setup_grant_button': 'Allow protection & continue',
      'setup_manual_only': 'Manual scan only (no SMS access)',
      'monitoring_enabled': 'Automatic SMS monitoring is on.',
      'monitoring_needs_sms':
          'Automatic SMS monitoring requires the Android app (SMS permission). Use manual scan on this device.',
      'sender_line': 'From: %s',
      'sender_line_name': 'From: %s (%s)',
      'unknown_number': 'Unknown number',
      'scam_detected': 'SCAM DETECTED',
      'message_safe': 'MESSAGE SAFE',
      'scam_description':
          'This message matches known scam patterns and should be handled with extreme caution.',
      'safe_description': 'No scam patterns were detected in this message.',
      'risk_indicators': 'Risk Indicators',
      'risk_points':
          'â€¢ Suspicious request for money transfer\nâ€¢ Unknown or spoofed sender\nâ€¢ Unusual urgency detected',
      'original_message': 'ORIGINAL MESSAGE',
      'report_to_tcra': 'Report to TCRA',
      'agent_advice_title': 'Safety advice',
      'save_number_as_scam': 'Save sender number as scam',
      'number_saved_scam':
          'Number saved. You will be alerted when this sender texts again.',
      'no_sender_to_save':
          'No sender number to save. Analyze an incoming SMS or enter a number.',
      'number_removed': 'Number removed from scam list',
      'nav_home': 'Home',
      'nav_scan': 'Scan',
      'nav_history': 'History',
      'nav_profile': 'Profile',
      'home_headline': 'Safety Made for Real Life in Tanzania',
      'home_purpose':
          'ScamShield spots M-Pesa, Airtel Money, Tigo Pesa & fake-prize SMS scams before they reach you - in English and Kiswahili.',
      'home_purpose_kicker': 'PURPOSE â€¢ LENGO',
      'home_purpose_title': 'Why ScamShield exists',
      'home_purpose_body':
          'Fraudsters send fake "tuma hela" and prize messages every day. ScamShield uses SwahBERT AI to read the meaning of each SMS and warn you instantly - so you never send money or share PINs by mistake.',
      'home_how_title': 'How it works â€¢ Jinsi inavyofanya kazi',
      'home_step1_title': '1. Turn protection ON',
      'home_step1_desc':
          'Allow SMS + notifications once. New messages are checked automatically.',
      'home_step2_title': '2. Scan or relax',
      'home_step2_desc':
          'Auto-monitoring watches inbox, or tap + / Scan to paste any message.',
      'home_step3_title': '3. Act + report',
      'home_step1_more':
          'Tap the switch once. From then on, every new SMS is checked the second it arrives - even when the app is closed.',
      'home_step2_more':
          'Paste any message for an instant verdict: scam risk %, clear advice. Or do nothing - monitoring runs by itself.',
      'home_step3_more':
          'Got a scam verdict? Block the number and report it. One tap protects the whole community.',
      'home_step3_desc':
          'Get scam verdict + safety advice, save numbers, report to TCRA 15040.',
      'home_ai_title': 'SwahBERT AI - your robot guard',
      'home_ai_body':
          'On-device patterns + cloud Swahili transformer understand "Hongera umeshinda", "tuma kwa wakala" tricks. Private over HTTPS, history stays on this phone.',
      'home_ai_cta': 'Check a message with AI',
      'protection_ready': 'Ready to protect',
      'protection_active': 'Live protection ON',
      'monitoring_on_line':
          'Incoming SMS are analyzed automatically. You will get alerts for scams.',
      'monitoring_off_line':
          'Auto monitoring is off. Turn on the switch below to analyze new SMS automatically.',
      'automatic_monitoring': 'Automatic Monitoring',
      'monitoring_desc':
          'Protect against suspicious SMS and phishing calls in real-time.',
      'start_manual_scan_caps': 'START MANUAL SCAN',
      'start_scan': 'Start Manual Scan',
      'view_all': 'View All',
      'stay_aware': 'Stay Aware â€¢ Kaa Macho',
      'avoid_scams_title': "Avoid 'Tuma Hela' Scams",
      'avoid_scams_subtitle':
          'EPUKA UTAPELI WA "TUMA HELA KWA NAMBA HII"',
      'avoid_scams_desc':
          'Legitimate organizations will never ask for money, PIN or codes via SMS.',
      'profile_title': 'Profile',
      'profile_subtitle': 'Actions, permissions & safety score',
      'profile_user_name': 'ScamShield User',
      'profile_user_sub': 'Protected â€¢ Mlinzi wa SMS',
      'profile_actions': 'QUICK ACTIONS',
      'profile_scan_title': 'Manual scan',
      'profile_scan_sub': 'Paste any SMS for instant AI verdict',
      'profile_history_title': 'Scan history',
      'profile_history_sub': 'Review past scams & safe messages',
      'profile_report_sub': 'Send scam SMS to TCRA 15040',
      'overview_title': 'Protection Overview',
      'overview_subtitle': 'Monitor your SMS safety',
      'overall_score': 'Overall Score',
      'stat_scams': 'Scams',
      'stat_scams_sub': 'Caught',
      'stat_safe': 'Safe',
      'stat_safe_sub': 'Verified',
      'stat_saved': 'Saved',
      'stat_saved_sub': 'Numbers',
      'score_very_strong': 'Very Strong',
      'score_strong': 'Strong',
      'score_at_risk': 'At Risk',
      'score_not_started': 'Not started',
      'score_hint_no_scans': 'Scan messages to build your score',
      'phone_contacts': 'PHONE CONTACTS',
      'contacts_access_title': 'Phone contacts access',
      'contacts_access_allowed':
          'Allowed - saved names shown, unknown numbers flagged',
      'contacts_access_denied':
          'Not allowed - results show raw numbers only',
      'allow': 'Allow',
      'allowed': 'Allowed',
      'all': 'All',
      'scams': 'Scams',
      'legitimate': 'Legitimate',
      'scam_tag': 'SCAM',
      'safe_tag': 'SAFE',
      'blocked_scam_numbers': 'BLOCKED SCAM NUMBERS',
      'blocked_numbers_empty':
          'No scam numbers saved yet. Save a number from scan results after a scam is detected.',
      'remove': 'Remove',
      'language_preferences': 'LANGUAGE PREFERENCES',
      'english': 'English',
      'kiswahili': 'Kiswahili',
      'general': 'GENERAL',
      'notifications': 'Notifications',
      'scam_alerts': 'Scam alerts',
      'scam_alerts_desc':
          'Show notifications when a risky SMS is detected',
      'appearance': 'APPEARANCE',
      'dark_theme': 'Dark theme',
      'dark_theme_desc': 'Easier on the eyes in low light',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',
      'privacy_policy_body':
          'ScamShield analyzes SMS text using our secure API (swahbert.qecure.online). We send only the message content and optional sender number. History and blocked numbers stay on your device. You control permissions and can disable monitoring anytime.',
      'terms_of_service_body':
          'ScamShield is an academic FYP tool for education. Results are automated, not legal advice. Do not share PINs or send money based on SMS alone. Report scams to TCRA (15040). By using this app you accept that detection may not be 100% accurate.',
      'ok': 'OK',
      'end_of_history': 'END OF HISTORY',
      'version': 'Version 1.2',
      'about': 'About ScamShield',
      'recent_scans': 'Recent Scans',
      'services': 'Services',
      'how_it_works': 'How It Works',
      'no_scans_yet': 'No scans yet',
      'no_scans_sub': 'Scan your first message',
      'svc_scan_title': 'Manual Scan',
      'svc_scan_sub': 'Paste SMS for AI verdict',
      'svc_ai_title': 'SwahBERT AI',
      'svc_ai_sub': 'Swahili + English',
      'svc_block_title': 'Blocked Numbers',
      'svc_block_sub': 'Instant scam alerts',
      'svc_report_title': 'Report Scammer',
      'svc_report_sub': 'Flag a number for everyone',
      'report_subtitle':
          'Tell the community about a number that tried to scam you. Flagged numbers trigger instant alerts on every ScamShield phone - and your details help the AI catch new tricks.',
      'report_number_label': 'Scammer number',
      'report_number_hint': '+255 7xx xxx xxx',
      'report_channel_label': 'How did they contact you?',
      'report_channel_sms': 'SMS message',
      'report_channel_call': 'Phone call',
      'report_category_label': 'Type of fraud',
      'report_subtype_label': 'Specific trick used',
      'report_paste_label': 'Paste the scam message (optional)',
      'report_paste_hint': 'Paste the full message here - it helps the AI learn',
      'report_submit': 'Submit report',
      'report_thanks_title': 'Report received',
      'report_thanks_body':
          'This number is now flagged for everyone using ScamShield. You will be alerted instantly if it contacts you again.',
      'report_error':
          'Could not submit the report. Check your internet and try again.',
      'report_invalid_number': 'Enter a valid phone number first.',
      'ai_banner': 'AI Scan',
      'swahbert_title': 'SwahBERT Number Check',
      'swahbert_hero': 'Check any number against community-reported scams',
      'swahbert_subtitle':
          'Paste or type a phone number and SwahBERT AI instantly tells you if it has been reported as a scam - and the type of scam it preys with.',
      'swahbert_total': 'reported numbers',
      'swahbert_types_tracked': 'scam types tracked',
      'swahbert_live_label': 'LIVE COMMUNITY REPORTS',
      'swahbert_live_sub': 'Sliding updates from the ScamShield community',
      'swahbert_empty':
          'No reported numbers yet. Be the first to report a scammer.',
      'swahbert_input_label': 'Number to check',
      'swahbert_input_hint': '+255 7xx xxx xxx',
      'swahbert_paste': 'Paste number',
      'swahbert_check': 'Check number',
      'swahbert_checking': 'Checking the community list...',
      'swahbert_invalid': 'Enter a valid phone number first.',
      'swahbert_hit_title': 'REPORTED SCAM NUMBER',
      'swahbert_hit_body':
          'This number appears in the community scam list. Do not send money, PINs or codes to it - and report it if it contacts you again.',
      'swahbert_clean_title': 'NO REPORTS FOUND',
      'swahbert_clean_body':
          'This number is not in the reported scam list yet. Stay careful - new scammers appear every day.',
      'swahbert_type_label': 'Type of scam',
      'swahbert_type_unknown': 'Community reported',
      'swahbert_reported_on': 'Reported on',
      'swahbert_new_badge': 'NEW',
      'swahbert_recent_title': 'RECENTLY REPORTED',
      'swahbert_not_specified': 'Not specified',
      'swahbert_tap_check': 'Tap to check any number',
    },
    'sw': {
      'app_name': 'ScamShield',
      'manual_text_analysis': 'Uchambuzi wa Maandishi',
      'scan_results': 'Matokeo ya Uchambuzi',
      'scan_hint': 'Weka au weka daboo ujumbe hapa...',
      'scan_description_input':
          'Weka ujumbe ukague mifumo ya ulaghai kabla ya kujibu au kutuma pesa.',
      'clear': 'Futa',
      'scan_content': 'Kagua Maandishi',
      'privacy_note': 'Kumbuka cha Faragha',
      'privacy_description':
          'Ujumbe unachambuliwa kupitia API ya SwahBERT (HTTPS). Ujumbe wa SMS pekee na namba ya mtumaji hutumwa kwa uainishaji.',
      'api_error':
          'Imeshindwa kufikia API ya ugunduzi wa ulaghai. Angalia mtandao na ujaribu tena.',
      'setup_welcome_title': 'Karibu ScamShield',
      'setup_why_permissions':
          'App hii hukusaidia kugundua SMS za ulaghai za Kiswahili (M-Pesa, Airtel, zawadi bandia). Unachagua ruhusa za kuruhusu.',
      'ob_feat_alerts': 'Arifa za ulaghai',
      'ob_feat_autoscan': 'Uchambuzi wa SMS kiotomatiki',
      'ob_feat_contacts': 'Majina yaliyohifadhiwa',
      'setup_permissions_list':
          '• Arifa - tahadhari za ulaghai\n• Kupokea SMS - kuchambua ujumbe mpya kiotomatiki\n• Anwani (hiari) - kuonyesha majina badala ya namba\n• Simu - kukuarifu watumaji wasiojulikana\n\nHatuisomi sanduku lako lote la ujumbe. SMS mpya zinazopokelewa tu wakati ulinji umewashwa.',
      'setup_privacy_safe':
          'Ujumbe wako unabaki faragha. Historia huhifadhiwa kwenye simu hii pekee. Unaweza kutumia ukaguzi wa mkono bila ruhusa ya SMS.',
      'setup_grant_button': 'Ruhusu ulinji & endelea',
      'setup_manual_only': 'Ukaguzi wa mkono tu (hakuna SMS)',
      'monitoring_enabled': 'Ufuatiliaji wa SMS kiotomatiki umewashwa.',
      'monitoring_needs_sms':
          'Ufuatiliaji wa SMS otomatiki unahitaji app ya Android (ruhusa ya SMS). Tumia ukaguzi wa mkono kwenye kifaa hiki.',
      'sender_line': 'Kutoka: %s',
      'sender_line_name': 'Kutoka: %s (%s)',
      'unknown_number': 'Namba haijulikani',
      'scam_detected': 'ULAGHAI UMEGUNDULIWA',
      'message_safe': 'UJUMBE NI SALAMA',
      'scam_description':
          'Ujumbe huu unafanana na mifumo ya ulaghai na unapaswa kushughulikiwa kwa tahadhari kubwa.',
      'safe_description': 'Hakuna mifumo ya ulaghai iliyogunduliwa kwenye ujumbe huu.',
      'risk_indicators': 'Vioo vya Hatari',
      'risk_points':
          'â€¢ Ombi la kutiliwa shaka la uhamisho wa pesa\nâ€¢ Mtumaji asiyejulikana\nâ€¢ Haraka isiyo ya kawaida imetambuliwa',
      'original_message': 'UJUMBE ASILI',
      'report_to_tcra': 'Ripoti kwa TCRA',
      'agent_advice_title': 'Ushauri wa usalama',
      'save_number_as_scam': 'Hifadhi namba ya mtumaji kama ulaghai',
      'number_saved_scam':
          'Namba imehifadhiwa. Utapata arifa mtumaji hiki akirudia kutuma ujumbe.',
      'no_sender_to_save':
          'Hakuna namba ya mtumaji ya kuhifadhi. Chambua SMS inayoingia au weka namba.',
      'number_removed': 'Namba imeondolewa kwenye orodha ya ulaghai',
      'nav_home': 'Nyumbani',
      'nav_scan': 'Kagua',
      'nav_history': 'Historia',
      'nav_profile': 'Wasifu',
      'home_headline': 'Usalama kwa Maisha Halisi Tanzania',
      'home_purpose':
          'ScamShield inatambua ulaghai wa M-Pesa, Airtel Money, Tigo Pesa & SMS za zawadi bandia kabla zitakufikia - kwa Kiingereza na Kiswahili.',
      'home_purpose_kicker': 'LENGO â€¢ MALENGO',
      'home_purpose_title': 'Kwa nini ScamShield ipo',
      'home_purpose_body':
          'Walaghai wanatuma ujumbe bandia wa "tuma hela" na zawadi kila siku. ScamShield inatumia AI ya SwahBERT kusoma maana ya kila SMS na kukuonya papo hapo - ili usitume pesa au kushiriki PIN kwa makosa.',
      'home_how_title': 'Inavyofanya kazi',
      'home_step1_title': '1. Washa ulinji',
      'home_step1_desc':
          'Ruhusu SMS + arifa mara moja. Ujumbe mpya huchambuliwa kiotomatiki.',
      'home_step2_title': '2. Kagua au tulia',
      'home_step2_desc':
          'Ufuatiliaji otomatiki unafuatilia sanduku, au bonyeza + / Kagua kuweka ujumbe wowote.',
      'home_step3_title': '3. Chukua hatua + ripoti',
      'home_step3_desc':
          'Pata uamuzi wa ulaghai + ushauri wa usalama, hifadhi namba, ripoti kwa TCRA 15040.',
      'home_step1_more':
          'Bonyeza kitufe mara moja. Kuanzia sasa kila SMS mpya hukaguliwa papo hapo inapofika - hata app ikiwa imefungwa.',
      'home_step2_more':
          'Bandika ujumbe wowote upate uamuzi wa haraka: hatari ya ulaghai %, ushauri wazi. Au fanya kitu - ufuatiliaji unajendeleza wewe.',
      'home_step3_more':
          'Ukipata uamuzi wa ulaghai? Funga namba na uiripoti. Bonyezo moja linalinda jamii yote.',
      'home_ai_title': 'AI ya SwahBERT - mlinzi wako roboti',
      'home_ai_body':
          'Mifumo ya kifaa + cloud ya Kiswahili inaelewa mbinu za "Hongera umeshinda", "tuma kwa wakala". Faragha kupitia HTTPS, historia inabaki kwenye simu hii.',
      'home_ai_cta': 'Kagua ujumbe kwa AI',
      'protection_ready': 'Tayari kulinda',
      'protection_active': 'Ulinji Hai UMEWASHWA',
      'monitoring_on_line':
          'SMS zinazoingia huchambuliwa kiotomatiki. Utapata arifa za ulaghai.',
      'monitoring_off_line':
          'Ufuatiliaji otomatiki umefungwa. Washa swishi hapa chini kuchambua SMS mpya kiotomatiki.',
      'automatic_monitoring': 'Ufuatiliaji wa Moja kwa Moja',
      'monitoring_desc':
          'Linda dhidi ya SMS za kutiliwa shaka na simu za uvuvi kwa wakati halisi.',
      'start_manual_scan_caps': 'ANZA UKAGUZI SASA',
      'start_scan': 'Anza Ukaguzi',
      'view_all': 'Ona Zote',
      'stay_aware': 'Kaa Macho',
      'avoid_scams_title': 'Epuka Ulaghai wa "Tuma Hela"',
      'avoid_scams_subtitle':
          'EPUKA UTAPELI WA "TUMA HELA KWA NAMBA HII"',
      'avoid_scams_desc':
          'Mashirika halisi haytaombwi pesa, PIN au msimbo kwa SMS.',
      'profile_title': 'Wasifu',
      'profile_subtitle': 'Vitendo, ruhusa & alama ya usalama',
      'profile_user_name': 'Mtumiaji wa ScamShield',
      'profile_user_sub': 'Umevinjwa â€¢ Mlinzi wa SMS',
      'profile_actions': 'VITENDO VYA HARAKA',
      'profile_scan_title': 'Ukaguzi wa mkono',
      'profile_scan_sub': 'Weka SMS yoyote kwa uamuzi wa AI wa papo hapo',
      'profile_history_title': 'Historia ya ukaguzi',
      'profile_history_sub': 'Kagua ulaghai & ujumbe salama wa nyuma',
      'profile_report_sub': 'Tuma SMS ya ulaghai kwa TCRA 15040',
      'overview_title': 'Muhtasari wa Ulinji',
      'overview_subtitle': 'Fuatilia usalama wako wa SMS',
      'overall_score': 'Alama kwa Ujumla',
      'stat_scams': 'Ulaghai',
      'stat_scams_sub': 'Umetekwa',
      'stat_safe': 'Salama',
      'stat_safe_sub': 'Imethibitishwa',
      'stat_saved': 'Hifadhiwa',
      'stat_saved_sub': 'Namba',
      'score_very_strong': 'Imara Sana',
      'score_strong': 'Imara',
      'score_at_risk': 'Kwenye Hatari',
      'score_not_started': 'Haijaanza',
      'score_hint_no_scans': 'Kagua ujumbe kujenga alama zako',
      'phone_contacts': 'ANWANI ZA SIMU',
      'contacts_access_title': 'Ruhusa ya anwani za simu',
      'contacts_access_allowed':
          'Ruhusiwa - majina yamehifadhiwa yanawekwa, namba zisizojulikana zinawekwa alama',
      'contacts_access_denied':
          'Haijaruhusiwa - matokeo yanaonyesha namba ghafi tu',
      'allow': 'Ruhusu',
      'allowed': 'Ruhusiwa',
      'all': 'Zote',
      'scams': 'Ulaghai',
      'legitimate': 'Halali',
      'scam_tag': 'ULAGHAI',
      'safe_tag': 'SALAMA',
      'blocked_scam_numbers': 'NAMBA ZA ULAGHAI ZILIZOFUNGWA',
      'blocked_numbers_empty':
          'Hakuna namba za ulaghai zilizohifadhiwa. Hifadhi namba kutoka matokeo ya ukaguzi ulaghai unapogunduliwa.',
      'remove': 'Ondoa',
      'language_preferences': 'MAPENDO YA LUGHA',
      'english': 'Kiingereza',
      'kiswahili': 'Kiswahili',
      'general': 'JUMLA',
      'notifications': 'Arifa',
      'scam_alerts': 'Tahadhari za ulaghai',
      'scam_alerts_desc':
          'Onyesha arifa SMS hatari inapogunduliwa',
      'appearance': 'MWONEKANO',
      'dark_theme': 'Mandhari ya giza',
      'dark_theme_desc': 'Rahisi kwa macho penye mwanga mdogo',
      'privacy_policy': 'Sera ya Faragha',
      'terms_of_service': 'Masharti ya Huduma',
      'privacy_policy_body':
          'ScamShield inachambua maandishi ya SMS kwa kutumia API yetu salama (swahbert.qecure.online). Tunatuma yaliyomo kwa ujumbe na namba ya mtumaji hiari tu. Historia na namba zilizofungwa zinabaki kwenye kifaa chako. Unadhibiti ruhusa na unaweza kuzima ufuatiliaji wakati wowote.',
      'terms_of_service_body':
          'ScamShield ni zana ya kielimu ya FYP. Matokeo ni ya otomatiki, sio ushauri wa kisheria. Usishiriki PIN au kutuma pesa kwa kutegemea SMS pekee. Ripoti ulaghai kwa TCRA (15040). Kwa kutumia app hii unakubali kwamba ugunduzi unaweza usiwe sahihi 100%.',
      'ok': 'Sawa',
      'end_of_history': 'MWISHO WA HISTORIA',
      'version': 'Toleo 1.2',
      'about': 'Kuhusu ScamShield',
      'recent_scans': 'Uchambuzi wa Karibuni',
      'services': 'Huduma',
      'how_it_works': 'Inavyofanya Kazi',
      'no_scans_yet': 'Hakuna uchambuzi',
      'no_scans_sub': 'Kagua ujumbe wako wa kwanza',
      'svc_scan_title': 'Kagua Mkono',
      'svc_scan_sub': 'Weka SMS kwa AI',
      'svc_ai_title': 'AI ya SwahBERT',
      'svc_ai_sub': 'Kiswahili + Kiingereza',
      'svc_block_title': 'Namba Zilizofungwa',
      'svc_block_sub': 'Arifa za papo hapo',
      'svc_report_title': 'Ripoti Mtapeli',
      'svc_report_sub': 'Weka alama kwa kila mtu',
      'report_subtitle':
          'Wajulishe jamii kuhusu namba iliyokujaribu kutapeli. Namba zilizoripotiwa hutoa arifa papo hapo kwenye kila simu ya ScamShield - na maelezo yako husaidia AI kutambua ulaghai mpya.',
      'report_number_label': 'Namba ya mtapeli',
      'report_number_hint': '+255 7xx xxx xxx',
      'report_channel_label': 'Walikuangushaje?',
      'report_channel_sms': 'Ujumbe wa SMS',
      'report_channel_call': 'Simu ya maneno',
      'report_category_label': 'Aina ya utapeli',
      'report_subtype_label': 'Zoezi maalum walilotumia',
      'report_paste_label': 'Bandika ujumbe wa utapeli (hiari)',
      'report_paste_hint': 'Bandika ujumbe mzima hapa - husaidia AI kujifunza',
      'report_submit': 'Tuma ripoti',
      'report_thanks_title': 'Ripoti imepokelewa',
      'report_thanks_body':
          'Namba hii sasa imewekwa alama kwa kila mtu anayetumia ScamShield. Utaarifiwa papo hapo ikitaka kukushughulikia tena.',
      'report_error':
          'Imeshindikana kutuma ripoti. Angalia mtandao na ujaribu tena.',
      'report_invalid_number': 'Kwanza weka namba sahihi ya simu.',
      'ai_banner': 'Kagua kwa AI',
      'swahbert_title': 'Ukaguzi wa Namba - SwahBERT',
      'swahbert_hero': 'Kagua namba yoyote kulinganisha na ulaghai ulioripotiwa',
      'swahbert_subtitle':
          'Bandika au andika namba ya simu na SwahBERT AI itakujulisha papo hapo kama imeripotiwa kuwa ulaghai - na aina ya utapeli wanaofanyizia.',
      'swahbert_total': 'namba zilizoripotiwa',
      'swahbert_types_tracked': 'aina za utapeli zinazofuatiliwa',
      'swahbert_live_label': 'RIPOTI ZA JAMII MUDA HALISI',
      'swahbert_live_sub': 'Taarifa zinazosonga kutoka kwa jamii ya ScamShield',
      'swahbert_empty':
          'Hakuna namba zilizoripotiwa bado. Kuwa wa kwanza kuripoti mtapeli.',
      'swahbert_input_label': 'Namba ya kukagua',
      'swahbert_input_hint': '+255 7xx xxx xxx',
      'swahbert_paste': 'Bandika namba',
      'swahbert_check': 'Kagua namba',
      'swahbert_checking': 'Inakagua orodha ya jamii...',
      'swahbert_invalid': 'Kwanza weka namba sahihi ya simu.',
      'swahbert_hit_title': 'NAMBA YA ULAGHAI ILIORIPOTIWA',
      'swahbert_hit_body':
          'Namba hii iko kwenye orodha ya ulaghai ya jamii. Usitume pesa, PIN au misimbo kwayo - na iiripoti ikitaka kukushughulikia tena.',
      'swahbert_clean_title': 'HAKUNA RIPOTI',
      'swahbert_clean_body':
          'Namba hii haipo kwenye orodha ya ulaghai bado. Kuwa makini - walaghai wapya huonekana kila siku.',
      'swahbert_type_label': 'Aina ya utapeli',
      'swahbert_type_unknown': 'Iliyoripotiwa na jamii',
      'swahbert_reported_on': 'Iliripotiwa',
      'swahbert_new_badge': 'MPYA',
      'swahbert_recent_title': 'ZILIZORIPOTIWA HIVI KARIBUNI',
      'swahbert_not_specified': 'Haijabainishwa',
      'swahbert_tap_check': 'Bonyeza kukagua namba yoyote',
    },
  };

  static String t(String key, {required String lang}) =>
      _strings[lang]?[key] ?? _strings['en']?[key] ?? key;

  static String senderLine(String lang, String value) =>
      t('sender_line', lang: lang).replaceFirst('%s', value);

  static String senderLineName(String lang, String name, String number) =>
      t('sender_line_name', lang: lang)
          .replaceFirst('%s', name)
          .replaceFirst('%s', number);
}
