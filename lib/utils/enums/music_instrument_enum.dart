import 'package:gc_customer_app/primitives/music_icons_system.dart';

enum MusicInstrumentEnum {
  acousticGuitar,
  bassGuitar,
  bassoon,
  brass,
  cello,
  clarinet,
  doubleBass,
  drumKit,
  electricGuitar,
  flute,
  marchingPercussion,
  oboe,
  orchestral,
  saxophone,
  trombone,
  trumpet,
  tuba,
  viola,
  violin,
  woodWing,
  unknown,
}

abstract class MusicInstrument {
  static MusicInstrumentEnum getMusicInstrumentFromString(
      String instrumentName) {
    switch (instrumentName) {
      case 'Acoustic Guitar':
      case 'Guitar':
        return MusicInstrumentEnum.acousticGuitar;
      case 'Bass Guitar':
        return MusicInstrumentEnum.bassGuitar;
      case 'Bassoon':
        return MusicInstrumentEnum.bassoon;
      case 'Brass':
        return MusicInstrumentEnum.brass;
      case 'Cello':
        return MusicInstrumentEnum.cello;
      case 'Clarinet':
        return MusicInstrumentEnum.clarinet;
      case 'Double Bass':
        return MusicInstrumentEnum.doubleBass;
      case 'Drum':
        return MusicInstrumentEnum.drumKit;
      case 'Electric Guitar':
        return MusicInstrumentEnum.electricGuitar;
      case 'Flute':
        return MusicInstrumentEnum.flute;
      case 'Marching Percussion':
        return MusicInstrumentEnum.marchingPercussion;
      case 'Oboe':
        return MusicInstrumentEnum.oboe;
      case 'Band & Orchestral':
        return MusicInstrumentEnum.orchestral;
      case 'Saxophone':
        return MusicInstrumentEnum.saxophone;
      case 'Trombone':
        return MusicInstrumentEnum.trombone;
      case 'Trumpet':
        return MusicInstrumentEnum.trumpet;
      case 'Tuba':
        return MusicInstrumentEnum.tuba;
      case 'Viola':
        return MusicInstrumentEnum.viola;
      case 'Violin':
        return MusicInstrumentEnum.violin;
      case 'Wood Wing':
        return MusicInstrumentEnum.woodWing;
      default:
        return MusicInstrumentEnum.unknown;
    }
  }

  static String getInstrumentIcon(MusicInstrumentEnum musicInstrumentEnum) {
    switch (musicInstrumentEnum) {
      case MusicInstrumentEnum.acousticGuitar:
        return MusicIconsSystem.acousticGuitar;
      case MusicInstrumentEnum.bassGuitar:
        return MusicIconsSystem.bassGuitar;
      case MusicInstrumentEnum.bassoon:
        return MusicIconsSystem.bassoon;
      case MusicInstrumentEnum.brass:
        return MusicIconsSystem.brass;
      case MusicInstrumentEnum.cello:
        return MusicIconsSystem.cello;
      case MusicInstrumentEnum.clarinet:
        return MusicIconsSystem.clarinet;
      case MusicInstrumentEnum.doubleBass:
        return MusicIconsSystem.doubleBass;
      case MusicInstrumentEnum.drumKit:
        return MusicIconsSystem.drumKit;
      case MusicInstrumentEnum.electricGuitar:
        return MusicIconsSystem.electricGuitar;
      case MusicInstrumentEnum.flute:
        return MusicIconsSystem.flute;
      case MusicInstrumentEnum.marchingPercussion:
        return MusicIconsSystem.marchingPercussion;
      case MusicInstrumentEnum.oboe:
        return MusicIconsSystem.oboe;
      case MusicInstrumentEnum.orchestral:
        return MusicIconsSystem.orchestra;
      case MusicInstrumentEnum.saxophone:
        return MusicIconsSystem.saxophone;
      case MusicInstrumentEnum.trombone:
        return MusicIconsSystem.trombone;
      case MusicInstrumentEnum.trumpet:
        return MusicIconsSystem.trumpet;
      case MusicInstrumentEnum.tuba:
        return MusicIconsSystem.tuba;
      case MusicInstrumentEnum.viola:
        return MusicIconsSystem.viola;
      case MusicInstrumentEnum.violin:
        return MusicIconsSystem.violin;
      case MusicInstrumentEnum.woodWing:
        return MusicIconsSystem.woodWing;
      case MusicInstrumentEnum.unknown:
        return MusicIconsSystem.acousticGuitar;
    }
  }
}
