package messages

func transformDeprecated(msg Message) Message {
	switch m := msg.(type) {
	case *JSExceptionDeprecated:
		return &JSException{
			Name:     m.Name,
			Message:  m.Message,
			Payload:  m.Payload,
			Metadata: "{}",
		}
	case *Fetch:
		return &NetworkRequest{
			Type:      "fetch",
			Method:    m.Method,
			URL:       m.URL,
			Request:   m.Request,
			Response:  m.Response,
			Status:    m.Status,
			Timestamp: m.Timestamp,
			Duration:  m.Duration,
		}
	case *IssueEventDeprecated:
		return &IssueEvent{
			MessageID:     m.MessageID,
			Timestamp:     m.Timestamp,
			Type:          m.Type,
			ContextString: m.ContextString,
			Context:       m.Context,
			Payload:       m.Payload,
			URL:           "",
		}
	case *ResourceTimingDeprecated:
		return &ResourceTiming{
			Timestamp:       m.Timestamp,
			Duration:        m.Duration,
			TTFB:            m.TTFB,
			HeaderSize:      m.HeaderSize,
			EncodedBodySize: m.EncodedBodySize,
			DecodedBodySize: m.DecodedBodySize,
			URL:             m.URL,
			Initiator:       m.Initiator,
			TransferredSize: 0,
			Cached:          false,
		}
	case *MouseClickDeprecated:
		return &MouseClick{
			ID:             m.ID,
			HesitationTime: m.HesitationTime,
			Label:          m.Label,
			Selector:       m.Selector,
			NormalizedX:    101, // 101 is a magic number to signal that the value is not present
			NormalizedY:    101, // 101 is a magic number to signal that the value is not present
		}
	case *SetPageLocationDeprecated:
		return &SetPageLocation{
			URL:             m.URL,
			Referrer:        m.Referrer,
			NavigationStart: m.NavigationStart,
			DocumentTitle:   "",
		}
	case *PageEventDeprecated:
		return &PageEvent{
			MessageID:                  m.MessageID,
			Timestamp:                  m.Timestamp,
			URL:                        m.URL,
			Referrer:                   m.Referrer,
			Loaded:                     m.Loaded,
			RequestStart:               m.RequestStart,
			ResponseStart:              m.ResponseStart,
			ResponseEnd:                m.ResponseEnd,
			DomContentLoadedEventStart: m.DomContentLoadedEventStart,
			DomContentLoadedEventEnd:   m.DomContentLoadedEventEnd,
			LoadEventStart:             m.LoadEventStart,
			LoadEventEnd:               m.LoadEventEnd,
			FirstPaint:                 m.FirstPaint,
			FirstContentfulPaint:       m.FirstContentfulPaint,
			SpeedIndex:                 m.SpeedIndex,
			VisuallyComplete:           m.VisuallyComplete,
			TimeToInteractive:          m.TimeToInteractive,
			WebVitals:                  "",
		}
	}
	return msg
}
