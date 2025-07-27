// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      body: json['body'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      priority: $enumDecode(_$NotificationPriorityEnumMap, json['priority']),
      isRead: json['isRead'] as bool,
      data: json['data'] as Map<String, dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      actionUrl: json['actionUrl'] as String?,
      actionText: json['actionText'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
    );

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'priority': _$NotificationPriorityEnumMap[instance.priority]!,
      'isRead': instance.isRead,
      'data': instance.data,
      'imageUrl': instance.imageUrl,
      'actionUrl': instance.actionUrl,
      'actionText': instance.actionText,
      'created_at': instance.createdAt.toIso8601String(),
      'read_at': instance.readAt?.toIso8601String(),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.rideRequest: 'RIDE_REQUEST',
  NotificationType.rideAccepted: 'RIDE_ACCEPTED',
  NotificationType.rideStarted: 'RIDE_STARTED',
  NotificationType.rideCompleted: 'RIDE_COMPLETED',
  NotificationType.paymentReceived: 'PAYMENT_RECEIVED',
  NotificationType.walletTopup: 'WALLET_TOPUP',
  NotificationType.systemUpdate: 'SYSTEM_UPDATE',
  NotificationType.promotion: 'PROMOTION',
  NotificationType.general: 'GENERAL',
};

const _$NotificationPriorityEnumMap = {
  NotificationPriority.low: 'LOW',
  NotificationPriority.normal: 'NORMAL',
  NotificationPriority.high: 'HIGH',
  NotificationPriority.urgent: 'URGENT',
};

NotificationRequest _$NotificationRequestFromJson(Map<String, dynamic> json) =>
    NotificationRequest(
      title: json['title'] as String,
      body: json['body'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      priority: $enumDecode(_$NotificationPriorityEnumMap, json['priority']),
      data: json['data'] as Map<String, dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      actionUrl: json['actionUrl'] as String?,
      actionText: json['actionText'] as String?,
    );

Map<String, dynamic> _$NotificationRequestToJson(
        NotificationRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'body': instance.body,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'priority': _$NotificationPriorityEnumMap[instance.priority]!,
      'data': instance.data,
      'imageUrl': instance.imageUrl,
      'actionUrl': instance.actionUrl,
      'actionText': instance.actionText,
    };

PaginatedNotificationList _$PaginatedNotificationListFromJson(
        Map<String, dynamic> json) =>
    PaginatedNotificationList(
      results: (json['results'] as List<dynamic>)
          .map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: (json['count'] as num).toInt(),
      next: json['next'] as String?,
      previous: json['previous'] as String?,
    );

Map<String, dynamic> _$PaginatedNotificationListToJson(
        PaginatedNotificationList instance) =>
    <String, dynamic>{
      'results': instance.results,
      'count': instance.count,
      'next': instance.next,
      'previous': instance.previous,
    };
