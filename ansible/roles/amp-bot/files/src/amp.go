package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
)

type AMPClient struct {
	BaseURL    string
	InstanceID string
	http       *http.Client
}

func NewAMPClient(baseURL, instanceID string) *AMPClient {
	return &AMPClient{
		BaseURL:    baseURL,
		InstanceID: instanceID,
		http:       &http.Client{},
	}
}

// TriggerWebhook fires a named webhook event configured in AMP's Scheduler,
// using AMP's officially documented inbound webhook mechanism.
func (c *AMPClient) TriggerWebhook(webhookToken, payload string) error {
	body := map[string]interface{}{
		"payload":   payload,
		"data":      "",
		"SESSIONID": webhookToken,
	}

	data, err := json.Marshal(body)
	if err != nil {
		return err
	}

	url := fmt.Sprintf("%s/API/ADSModule/Servers/%s/API/WebhookPlugin/TriggerWebhookEvent", c.BaseURL, c.InstanceID)

	req, err := http.NewRequest("POST", url, bytes.NewReader(data))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
	req.Header.Set("Authorize", "Bearer "+webhookToken)

	resp, err := c.http.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("webhook trigger failed: HTTP %d", resp.StatusCode)
	}
	return nil
}
