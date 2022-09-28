package slack

import (
	"github.com/slack-go/slack"
	"log"
)

const (
	Heart       = ":heart:"
	BrokenHeart = ":broken_heart:"
	GreenHeart  = ":green_heart:"
)

type Notifier interface {
	NotifyError(message string, sub string)
	NotifySuccess(message string, sub string)
	NotifyException(message string, sub string)
}

type slackNotifier struct {
	slackWebhookUrl string
}

func GetService(slackWebhookUrl string) Notifier {
	return &slackNotifier{
		slackWebhookUrl: slackWebhookUrl,
	}
}

func createMessage(prefix string, message string, sub string) slack.WebhookMessage {
	blocks := []slack.Block{
		slack.NewHeaderBlock(
			slack.NewTextBlockObject(slack.PlainTextType, "Auto rollback", true, false),
		),
		slack.NewSectionBlock(
			slack.NewTextBlockObject(slack.PlainTextType, prefix+" "+message, true, false),
			[]*slack.TextBlockObject{},
			nil,
		),
	}

	if len(sub) > 0 {
		ctxBlock := slack.NewContextBlock("",
			slack.NewTextBlockObject(slack.MarkdownType, sub, false, false),
		)
		blocks = append(blocks, ctxBlock)
	}

	return slack.WebhookMessage{Blocks: &slack.Blocks{
		BlockSet: blocks,
	}}
}

func (s slackNotifier) NotifyError(message string, sub string) {
	msg := createMessage(Heart, message, sub)
	err := slack.PostWebhook(s.slackWebhookUrl, &msg)
	if err != nil {
		log.Fatalln(err)
	}
}

func (s slackNotifier) NotifySuccess(message string, sub string) {
	msg := createMessage(GreenHeart, message, sub)
	err := slack.PostWebhook(s.slackWebhookUrl, &msg)
	if err != nil {
		log.Fatalln(err)
	}
}

func (s slackNotifier) NotifyException(message string, sub string) {
	msg := createMessage(BrokenHeart, message, sub)
	err := slack.PostWebhook(s.slackWebhookUrl, &msg)
	if err != nil {
		log.Fatalln(err)
	}
}
