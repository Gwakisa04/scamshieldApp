import 'package:flutter/material.dart';

class FraudSubtype {
  final String sw;
  final String en;
  const FraudSubtype(this.sw, this.en);
}

class FraudCategory {
  final int id;
  final String sw;
  final String en;
  final IconData icon;
  final List<FraudSubtype> subtypes;
  const FraudCategory(this.id, this.sw, this.en, this.icon, this.subtypes);
}

const fraudCategories = <FraudCategory>[
  FraudCategory(1, 'Kuomba pesa kwa huruma', 'Begging for money with pity',
      Icons.volunteer_activism_rounded, [
    FraudSubtype('Utapeli wa ugonjwa', 'Fake illness'),
    FraudSubtype('Utapeli wa mtoto mgonjwa', 'Sick child'),
    FraudSubtype('Utapeli wa ajali', 'Accident'),
    FraudSubtype('Utapeli wa msiba', 'Fake funeral'),
    FraudSubtype('Utapeli wa chakula / amekwama', 'No food / stranded'),
    FraudSubtype('Kujifanya ndugu au rafiki (namba mpya)', 'Pretending to be relative'),
    FraudSubtype('Kuchangisha matibabu bandia', 'Fake medical fundraising'),
  ]),
  FraudCategory(2, 'Viwanja na mali isiyohamishika', 'Land & property', Icons.map_rounded, [
    FraudSubtype('Viwanja hewa (hakipo)', 'Non-existent plot'),
    FraudSubtype('Kuuza kiwanja cha mtu mwingine', 'Selling someone else\'s plot'),
    FraudSubtype('Kiwanja kimoja kuuzwa mara nyingi', 'One plot sold to many'),
    FraudSubtype('Ramani au hati zilizoghushiwa', 'Forged maps / documents'),
    FraudSubtype('Dalali feki', 'Fake agent'),
    FraudSubtype('Malipo ya awali ya booking', 'Upfront booking fee'),
    FraudSubtype('Viwanja vya serikali feki', 'Fake government plots'),
    FraudSubtype('Bei ya kutupa ili kulazimisha malipo', 'Dump price pressure'),
  ]),
  FraudCategory(3, 'Pesa kwa simu na mitandao', 'Mobile money & telecom',
      Icons.smartphone_rounded, [
    FraudSubtype('Ujumbe wa "nimekutumia pesa kimakosa"', 'Wrongly sent money'),
    FraudSubtype('Kuomba kurejesha pesa kabla ya kuhakiki', 'Refund before checking'),
    FraudSubtype('SMS / screenshot za malipo feki', 'Fake payment SMS'),
    FraudSubtype('Kuomba PIN au OTP', 'Asking for PIN / OTP'),
    FraudSubtype('Akaunti imefungwa (bandia)', 'Account locked'),
    FraudSubtype('Kujifanya huduma kwa wateja', 'Fake customer care'),
    FraudSubtype('Kuomba vocha au muda wa maongezi', 'Asking for voucher'),
    FraudSubtype('Ujumbe bandia kwa wakala wa pesa', 'Fake agent messages'),
  ]),
  FraudCategory(4, 'Ajira na biashara', 'Jobs & business', Icons.work_outline_rounded, [
    FraudSubtype('Kazi hewa na ada za usaili', 'Fake job, interview fee'),
    FraudSubtype('Ajira za nje (visa/tiketi)', 'Jobs abroad, visa fee'),
    FraudSubtype('Zabuni na mikataba hewa', 'Fake contracts / tenders'),
    FraudSubtype('Uwekezaji wa faida kubwa haraka', 'Big quick returns'),
    FraudSubtype('Network marketing / kuingiza watu', 'Pyramid scheme'),
    FraudSubtype('Mikopo hewa na processing fee', 'Fake loans, fees'),
    FraudSubtype('Bidhaa bei rahisi mno (simu, TV)', 'Too-cheap goods'),
    FraudSubtype('Kudai malipo ya awali ya oda', 'Upfront order payment'),
  ]),
  FraudCategory(5, 'Mapenzi na mahusiano', 'Romance & relationships',
      Icons.favorite_rounded, [
    FraudSubtype('Romance scam (urafiki mtandaoni)', 'Romance scam'),
    FraudSubtype('Mpenzi amekwama airport/nje ya nchi', 'Stranded lover abroad'),
    FraudSubtype('Zawadi kutoka nje na ushuru', 'Gift from abroad, customs fee'),
    FraudSubtype('Utapeli wa ndoa', 'Marriage promise'),
    FraudSubtype('Kutishia kusambaza picha binafsi', 'Photo blackmail (sextortion)'),
  ]),
  FraudCategory(6, 'Taasisi na mamlaka', 'Institutions & authorities',
      Icons.account_balance_rounded, [
    FraudSubtype('TRA feki (deni la kodi/faini)', 'Fake TRA'),
    FraudSubtype('Polisi feki (ndugu amekamatwa)', 'Fake police'),
    FraudSubtype('Mahakama feki (kesi/hati)', 'Fake court'),
    FraudSubtype('Benki feki (taarifa za akaunti)', 'Fake bank'),
    FraudSubtype('TCRA feki (laini itafungwa)', 'Fake TCRA'),
    FraudSubtype('Malipo ya lazima ya serikali feki', 'Fake government fee'),
    FraudSubtype('Kuomba OTP kurekebisha laini', 'OTP for line fix'),
  ]),
  FraudCategory(7, 'Zawadi na bahati nasibu', 'Prizes & lottery',
      Icons.card_giftcard_rounded, [
    FraudSubtype('Umeshinda gari/bahati nasibu', 'Won a car / lottery'),
    FraudSubtype('Milioni kutoka kampuni ya simu', 'Millions from a telecom'),
    FraudSubtype('Zawadi ya kampuni bandia', 'Fake company prize'),
    FraudSubtype('Mkopo au kiwanja cha bure', 'Free loan / plot'),
    FraudSubtype('Kodi/gharama za kufikisha zawadi', 'Delivery / tax fee'),
    FraudSubtype('Kuomba namba ya siri kuthibitisha ushindi', 'Secret code to claim'),
  ]),
  FraudCategory(8, 'Utapeli mwingine wa kidijitali', 'Other digital scams',
      Icons.phishing_rounded, [
    FraudSubtype('Link feki ya benki/huduma (phishing)', 'Phishing link'),
    FraudSubtype('WhatsApp/akaunti iliyodukuliwa', 'Hacked WhatsApp'),
    FraudSubtype('Facebook/Instagram feki', 'Fake FB/IG account'),
    FraudSubtype('Matangazo ya bidhaa zisizokuwepo', 'Fake adverts'),
    FraudSubtype('Uwekezaji wa crypto bandia', 'Fake crypto investment'),
    FraudSubtype('Tips za betting kwa malipo', 'Paid betting tips'),
    FraudSubtype('Kurejesha akaunti za mitandao kwa pesa', 'Paid account recovery'),
    FraudSubtype('Sauti/picha bandia za AI (deepfake)', 'AI voice / deepfake'),
  ]),
];
