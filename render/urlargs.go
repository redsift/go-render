package main

import (
	"fmt"
	"gopkg.in/alecthomas/kingpin.v2"
	"net/url"
)

type urlList []*url.URL

func (i *urlList) Set(value string) error {
	url, err := url.Parse(value)
	if err != nil {
		return fmt.Errorf("'%s' is not an valid URL: %s", value, err.Error())
	}
	*i = append(*i, url)
	return nil

}

func (i *urlList) String() string {
	return ""
}

func (i *urlList) IsCumulative() bool {
	return true
}

func urlsList(s kingpin.Settings) (target *[]*url.URL) {
	target = new([]*url.URL)
	s.SetValue((*urlList)(target))
	return
}
