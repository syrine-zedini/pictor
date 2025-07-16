import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'usermodel.dart';
import 'ticketmodel.dart';

class Apiservice {
  static const String _baseUrl =
      'http://41.230.35.111:3030'; // Base URL pour tous les endpoints
  static const int timeoutSeconds = 30;
//creer un ticket
  static Future<Ticket> createTicket(
      CreateTicketCommand command, String token) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/tickets'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(command.toJson()),
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Ticket.fromJson(jsonDecode(response.body));
      } else {
        throw HttpException('Failed to create ticket: ${response.statusCode}');
      }
    } on SocketException {
      throw const SocketException('No Internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timeout');
    } on FormatException {
      throw const FormatException('Invalid response format');
    } catch (e) {
      throw Exception('Create ticket error: $e');
    }
  }

  // Récupérer un ticket par ID
  static Future<Ticket> getTicketById(String ticketId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tickets/$ticketId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return Ticket.fromJson(jsonDecode(response.body));
      } else {
        throw HttpException(
            'Failed to get ticket by ID: ${response.statusCode}');
      }
    } on SocketException {
      throw const SocketException('No Internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timeout');
    } on FormatException {
      throw const FormatException('Invalid response format');
    } catch (e) {
      throw Exception('Get ticket by ID error: $e');
    }
  }

  // Mettre à jour ticket
  static Future<Ticket> updateTicket(
      String ticketId, UpdateTicketCommand command, String token) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/api/tickets/$ticketId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(command.toJson()),
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return Ticket.fromJson(jsonDecode(response.body));
      } else {
        throw HttpException('Failed to update ticket: ${response.statusCode}');
      }
    } on SocketException {
      throw const SocketException('No Internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timeout');
    } on FormatException {
      throw const FormatException('Invalid response format');
    } catch (e) {
      throw Exception('Update ticket error: $e');
    }
  }

  // Ajouter commentaire

  static Future<Map<String, dynamic>> addComment(
      AddCommentCommand command, String token) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/tickets/comment'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(command.toJson()),
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response
            .body); // Supposant que l'API renvoie des détails sur le commentaire ajouté
      } else {
        throw HttpException('Failed to add comment: ${response.statusCode}');
      }
    } on SocketException {
      throw const SocketException('No Internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timeout');
    } on FormatException {
      throw const FormatException('Invalid response format');
    } catch (e) {
      throw Exception('Add comment error: $e');
    }
  }

  // Ajouter PJ ticket
  static Future<Map<String, dynamic>> addTicketAttachment(
      String ticketId, File attachmentFile, String token) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/tickets/$ticketId/attachments'),
      );
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });
      request.files.add(await http.MultipartFile.fromPath(
        'file', // Le nom du champ attendu par l'API pour le fichier
        attachmentFile.path,
      ));

      var response =
          await request.send().timeout(const Duration(seconds: timeoutSeconds));
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(responseBody);
      } else {
        throw HttpException(
            'Failed to add ticket attachment: ${response.statusCode} - $responseBody');
      }
    } on SocketException {
      throw const SocketException('No Internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timeout');
    } catch (e) {
      throw Exception('Add ticket attachment error: $e');
    }
  }

  // Ajouter PJ commentaire
  static Future<Map<String, dynamic>> addCommentAttachment(
      String commentId, File attachmentFile, String token) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/tickets/$commentId/attachmentscomment'),
      );
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });
      request.files.add(await http.MultipartFile.fromPath(
        'file', // Le nom du champ attendu par l'API pour le fichier
        attachmentFile.path,
      ));

      var response =
          await request.send().timeout(const Duration(seconds: timeoutSeconds));
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(responseBody);
      } else {
        throw HttpException(
            'Failed to add comment attachment: ${response.statusCode} - $responseBody');
      }
    } on SocketException {
      throw const SocketException('No Internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timeout');
    } catch (e) {
      throw Exception('Add comment attachment error: $e');
    }
  }

  // Fermer ticket
  static Future<void> closeTicket(
      String ticketId, String userId, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/tickets/closeticket/$ticketId/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode != 200) {
        throw HttpException('Failed to close ticket: ${response.statusCode}');
      }
    } on SocketException {
      throw const SocketException('No Internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timeout');
    } catch (e) {
      throw Exception('Close ticket error: $e');
    }
  }

  // Réouvrir ticket
  static Future<void> openTicket(
      String ticketId, String userId, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/tickets/openticket/$ticketId/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode != 200) {
        throw HttpException('Failed to open ticket: ${response.statusCode}');
      }
    } on SocketException {
      throw const SocketException('No Internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timeout');
    } catch (e) {
      throw Exception('Open ticket error: $e');
    }
  }

  //  Méthodes pour les nombres de tickets ---

  static Future<int> getOpenTicketsCount(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tickets/nbticketopen'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: timeoutSeconds));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as int;
      } else {
        throw HttpException(
            'Failed to get open tickets count: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting open tickets count: $e');
    }
  }

  static Future<int> getClosedTicketsCount(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tickets/nbticketclose'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: timeoutSeconds));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as int;
      } else {
        throw HttpException(
            'Failed to get closed tickets count: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting closed tickets count: $e');
    }
  }

  static Future<int> getInProgressTicketsCount(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tickets/nbticketencours'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: timeoutSeconds));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as int;
      } else {
        throw HttpException(
            'Failed to get in progress tickets count: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting in progress tickets count: $e');
    }
  }

  static Future<int> getOpenTicketsCountByUser(
      String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tickets/nbticketopenbyuser/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: timeoutSeconds));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as int;
      } else {
        throw HttpException(
            'Failed to get open tickets by user count: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting open tickets by user count: $e');
    }
  }

  static Future<int> getClosedTicketsCountByUser(
      String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tickets/nbticketclosebyuser/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: timeoutSeconds));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as int;
      } else {
        throw HttpException(
            'Failed to get closed tickets by user count: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting closed tickets by user count: $e');
    }
  }

  static Future<int> getInProgressTicketsCountByUser(
      String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tickets/nbticketencoursbyuser/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: timeoutSeconds));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as int;
      } else {
        throw HttpException(
            'Failed to get in progress tickets by user count: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting in progress tickets by user count: $e');
    }
  }

  // lister des tickets spécifiques par user

  static Future<List<Ticket>> listTicketsByUser(
      String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tickets/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Ticket.fromJson(item)).toList();
      } else {
        throw HttpException(
            'Failed to list tickets by user: ${response.statusCode}');
      }
    } on SocketException {
      throw const SocketException('No Internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timeout');
    } on FormatException {
      throw const FormatException('Invalid response format');
    } catch (e) {
      throw Exception('List tickets by user error: $e');
    }
  }

  static Future<int> getTotalTicketsCount(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tickets/count'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['total'] as int;
      } else {
        throw HttpException(
            'Failed to get total tickets count: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting total tickets count: $e');
    }
  }

  static Future<int> getPendingTicketsCount(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tickets/pending/count'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['pending'] as int;
      } else {
        throw HttpException(
            'Failed to get pending tickets count: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting pending tickets count: $e');
    }
  }
}
