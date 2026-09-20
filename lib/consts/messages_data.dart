import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String messageTitle;
  final String messageUrl;
  final String messageLength;
  final String messageSeries;
  final String messageDescription;
  final DateTime messageDate;
  final DateTime uploadDate;
  final String messageNotes;
  final String messageSpeaker;

  const MessageModel({
    required this.id,
    required this.messageTitle,
    required this.messageUrl,
    required this.messageLength,
    required this.messageSeries,
    required this.messageDescription,
    required this.messageDate,
    required this.uploadDate,
    required this.messageNotes,
    required this.messageSpeaker,
  });

  factory MessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return MessageModel(
      id: doc.id,
      messageTitle: data['messageTitle']?.toString() ?? '',
      messageUrl: data['messageUrl']?.toString() ?? '',
      messageLength: data['messageLength']?.toString() ?? '',
      messageSeries: data['messageSeries']?.toString() ?? '',
      messageDescription: data['messageDescription']?.toString() ?? '',
      messageDate: _dateFromFirestore(data['messageDate']),
      uploadDate: _dateFromFirestore(data['uploadDate']),
      messageNotes: data['messageNotes']?.toString() ?? '',
      messageSpeaker: data['messageSpeaker']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'messageTitle': messageTitle,
      'messageUrl': messageUrl,
      'messageLength': messageLength,
      'messageSeries': messageSeries,
      'messageDescription': messageDescription,
      'messageDate': Timestamp.fromDate(messageDate),
      'uploadDate': Timestamp.fromDate(uploadDate),
      'messageNotes': messageNotes,
      'messageSpeaker': messageSpeaker,
    };
  }

  static DateTime _dateFromFirestore(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }
}

class SeriesModel {
  final String id;
  final String seriesTitle;
  final String seriesImage;

  const SeriesModel({
    required this.id,
    required this.seriesTitle,
    required this.seriesImage,
  });

  factory SeriesModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return SeriesModel(
      id: doc.id,
      seriesTitle: data['seriesTitle']?.toString() ?? '',
      seriesImage: data['seriesImage']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'seriesTitle': seriesTitle, 'seriesImage': seriesImage};
  }
}

// final List<MessageModel> messages = [
//   MessageModel(
//     id: '123',
//     messageTitle: 'Revelation Part 1',
//     messageUrl: 'https://youtu.be/C19PsTdWvt8?si=mWVQRebrr3_pZhTE',
//     messageLength: '3:23:54',
//     messageSeries: 'Revelation',
//     messageDescription:
//         'A message about trusting God and continuing to walk in faith through every season of life.',
//     messageDate: DateTime(2026, 9, 4),
//     messageNotes:
//         'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',

//     messageSpeaker: 'Pastor Isaac Paul',
//   ),

//   MessageModel(
//     id: '123',

//     messageTitle: 'Revelation Part 2',
//     messageUrl: 'https://youtu.be/b9EcrFYO4Hw?si=FsLUfzHmZwEnvTPx',
//     messageLength: '2:31:03',
//     messageSeries: 'Revelation',
//     messageDescription:
//         'Discover the importance of prayer and how a consistent prayer life strengthens our relationship with God.',
//     messageDate: DateTime(2026, 8, 30),
//     messageNotes:
//         'https://end-time-message.org/component/easyfolderlistingpro/?view=download&format=raw&data=eNpNT1tywyAMvAsXsJ0maascI_lnSFgbptgwiDxmMrl7ZRNP-4PQSvuQoa6jXCfTnlQfg0VWB6ZdS6rxoxnADZeYvVTDMRdYnWzfFAedMszFIbN2ZrLnGH9mpoipKyNXLV4gUu06Gq7g8ufzSUrrBZu7r0qdzIi5lQxz2VfUW3Xw1FZSRkimuH9bwu19wMrdbEhdXFzS7VafJOsRN0zymrAk-iCFR3n_5J53FDySz-DVpxNpU4ocOWKS7fOCfgsj4-Zxr1wnSLwhxiGI7esXLiNrwg,,',
//     messageSpeaker: 'Pastor Isaac Paul',
//   ),

//   MessageModel(
//     id: '123',

//     messageTitle: 'Revelation Part 3',
//     messageUrl: 'https://youtu.be/-_xarouHAk4?si=IAU67ycp9q3RrTxh',
//     messageLength: '2:26:05',
//     messageSeries: 'Revelation',
//     messageDescription:
//         'Encouragement for trusting God when life becomes difficult and uncertain.',
//     messageDate: DateTime(2026, 9, 6),
//     messageNotes:
//         'God remains faithful even when our circumstances are difficult.',
//     messageSpeaker: 'Pastor Isaac Paul',
//   ),
// ];

// const List<SeriesModel> seriesData = [
//   SeriesModel(
//     seriesTitle: 'Revelation',
//     seriesImage: 'assets/series/revelation.jpg',
//   ),

//   SeriesModel(seriesTitle: 'Faith', seriesImage: 'assets/series/faith.jpg'),
// ];
