import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_event.dart';

class AdjustEventManager {
  // Map of event names to Adjust Event Tokens
  final Map<String, String> _adjEventToken = {
    'registration': 'abc123',
    'login': '456def',
    'purchase': 'fgh789',
  };

  // Method to map event names to Event Tokens (Adjust)
  String _getEventToken(String eventName) {
    return _adjEventToken[eventName] ?? 'unknown';
  }

  // New helper method to handle "revenue" parameter
  void _addRevenue(AdjustEvent adjustEvent, Map<String, dynamic>? revenue) {
    if (revenue != null && revenue.containsKey('amount') && revenue.containsKey('currency')) {
      double? amount = revenue['amount'] is num ? (revenue['amount'] as num).toDouble() : null;
      String? currency = revenue['currency'];

      if (amount != null && currency != null) {
        adjustEvent.setRevenue(amount, currency);
      }
    }
  }  

  // Helper method to dynamically add callback/partner parameters to Adjust Events
  void _addParameters(AdjustEvent adjustEvent, String paramType, Map<String, dynamic>? params) {
    if (params != null) {
      params.forEach((key, value) {
        if (value != null) {
          if (paramType == 'callback') {
            adjustEvent.addCallbackParameter(key, value);
          } else if (paramType == 'partner') {
            adjustEvent.addPartnerParameter(key, value);
          }
        }
      });
    }
  }

  // Main method to handle Adjust events
  void handleAdjustEvents(List<dynamic> args) {
    if (args.isEmpty || args[0] is! Map || !(args[0] as Map).containsKey('event_name')) {
      return; // Return early if input is invalid
    }

    Map<String, dynamic> eventArgs = args[0];
    String eventName = eventArgs['event_name'];
    String adjustEventToken = _getEventToken(eventName);

    if (adjustEventToken == 'unknown') return; // Early return for invalid token

    AdjustEvent adjustEvent = AdjustEvent(adjustEventToken);

    // Dynamically add any callback or partner parameters if they exist
    _addParameters(adjustEvent, 'callback', eventArgs['cb_param']);
    _addParameters(adjustEvent, 'partner', eventArgs['partner_param']);

    // Handle the revenue parameter if it exists
    _addRevenue(adjustEvent, eventArgs['revenue']);

    // Track the Adjust event
    Adjust.trackEvent(adjustEvent);
  }
}
