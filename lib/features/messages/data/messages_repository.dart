import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/utils/json_list.dart';
import 'models/contact_model.dart';
import 'models/message_model.dart';

class MessagesRepository {
  MessagesRepository(this._client);

  final ApiClient _client;

  Future<List<ContactModel>> fetchContacts() async {
    final response = await _client.get<dynamic>(ApiEndpoints.messagesContacts, v2: true);
    return extractJsonList(response.data).map(ContactModel.fromJson).toList();
  }

  Future<List<MessageModel>> fetchThread(int otherUserId) async {
    final path = ApiEndpoints.sub(ApiEndpoints.messagesThread, {'userId': otherUserId});
    final response = await _client.get<dynamic>(path, v2: true);
    return extractJsonList(response.data).map(MessageModel.fromJson).toList();
  }

  Future<MessageModel> send({required int recipientId, required String body, int? studentId}) async {
    final response = await _client.post<MessageModel>(
      ApiEndpoints.messagesSend,
      v2: true,
      body: {
        'recipient_id': recipientId,
        'body': body,
        if (studentId != null) 'student_id': studentId,
      },
      fromData: (json) => MessageModel.fromJson({
        ...(json as Map).cast<String, dynamic>(),
        'is_mine': true,
      }),
    );
    return response.data!;
  }
}
