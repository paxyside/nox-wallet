package logger

import "errors"

// ErrorChain unrolls a wrapped error into a slice of message strings,
// outermost first. Used by the gRPC handler to attach full diagnostic
// context to error logs without losing the wrap-by-wrap layering.
func ErrorChain(err error) []string {
	if err == nil {
		return nil
	}

	var chain []string
	for err != nil {
		chain = append(chain, err.Error())
		err = errors.Unwrap(err)
	}

	return chain
}
