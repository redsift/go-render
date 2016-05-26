package version

import "fmt"

func Version() string {
	if Tag == "" {
		if Commit == "" {
			return "unknown"
		}
		return Commit
	}
	return fmt.Sprintf("%s-%s", Tag, Commit)
}