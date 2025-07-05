import 'dart:io';

class Ticket {
  final String ticketId;
  final String sujet;
  final String description;
  final String statut; // Ex: Open, InProgress, Closed
  final String priority; // Ex: Critical, High, Medium, Low
  final DateTime dateCreation;
  final DateTime? dateAffectation;
  final DateTime? dateCloture;
  final String demandeurId; // userId du demandeur
  final String? assigneAId; // userId de l'utilisateur assigné
  final String? clientTicketId; // clientId du client lié au ticket

  Ticket({
    required this.ticketId,
    required this.sujet,
    required this.description,
    required this.statut,
    required this.priority,
    required this.dateCreation,
    this.dateAffectation,
    this.dateCloture,
    required this.demandeurId,
    this.assigneAId,
    this.clientTicketId,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketId: json['ticketId'] as String,
      sujet: json['sujet'] as String,
      description: json['description'] as String,
      statut: json['statut'] as String,
      priority: json['priority'] as String,
      dateCreation: DateTime.parse(json['dateCreation'] as String),
      dateAffectation: json['dateAffectation'] != null
          ? DateTime.parse(json['dateAffectation'] as String)
          : null,
      dateCloture: json['dateCloture'] != null
          ? DateTime.parse(json['dateCloture'] as String)
          : null,
      demandeurId: json['demandeurId'] as String,
      assigneAId: json['assigneAId'] as String?,
      clientTicketId: json['clientTicketId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      'sujet': sujet,
      'description': description,
      'statut': statut,
      'priority': priority,
      'dateCreation': dateCreation.toIso8601String(),
      'dateAffectation': dateAffectation?.toIso8601String(),
      'dateCloture': dateCloture?.toIso8601String(),
      'demandeurId': demandeurId,
      'assigneAId': assigneAId,
      'clientTicketId': clientTicketId,
    };
  }
}

// Commandes pour les requêtes POST/PUT

class CreateTicketCommand {
  final String sujet;
  final String description;
  final String priority;
  final String demandeurId;
  final String? clientId; // Optionnel

  CreateTicketCommand({
    required this.sujet,
    required this.description,
    required this.priority,
    required this.demandeurId,
    this.clientId,
  });

  Map<String, dynamic> toJson() {
    return {
      'sujet': sujet,
      'description': description,
      'priority': priority,
      'demandeurId': demandeurId,
      'clientId': clientId,
    };
  }
}

class UpdateTicketCommand {
  final String ticketId;
  final String sujet;
  final String description;
  final String statut;
  final String priority;
  // Vous pouvez ajouter d'autres champs à mettre à jour, comme 'assigneAId'
  final String? assigneAId;

  UpdateTicketCommand({
    required this.ticketId,
    required this.sujet,
    required this.description,
    required this.statut,
    required this.priority,
    this.assigneAId,
  });

  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      'sujet': sujet,
      'description': description,
      'statut': statut,
      'priority': priority,
      'assigneAId': assigneAId,
    };
  }
}

class AddCommentCommand {
  final String ticketId;
  final String userId;
  final String content;

  AddCommentCommand({
    required this.ticketId,
    required this.userId,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      'userId': userId,
      'content': content,
    };
  }
}