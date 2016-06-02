package main

import (
	"net/url"
	"fmt"
	"gopkg.in/alecthomas/kingpin.v2"
)

type urlList []*url.URL

func (i *urlList) Set(value string) error {
	if url, err := url.Parse(value); err != nil {
		return fmt.Errorf("'%s' is not an valid URL: %s", value, err.Error())
	} else {
		*i = append(*i, url)
		return nil
	}
}

func (i *urlList) String() string {
	return ""
}

func (i *urlList) IsCumulative() bool {
	return true
}

func URLSList(s kingpin.Settings) (target *[]*url.URL) {
	target = new([]*url.URL)
	s.SetValue((*urlList)(target))
	return
}
