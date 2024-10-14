package main

import (
	"encoding/json"
	"html/template"
	"net/http"
	"os"
	"time"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

type health struct {
	Status string `json:"status"`
}

const templ = `<!DOCTYPE html>
<html>

<head>
    <title>Workshop GitOps on Kubernetes</title>
</head>

<style>
	.container {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		height: 100vh;
	}
</style>

<body>
	<div class="container">
    	<h1>Workshop GitOps on Kubernetes</h1>
		<p>I am running in the <strong>{{ .Namespace }}</strong> namespace</p>
	</div>
</body>

</html>
`

func main() {
	log.Logger = zerolog.New(zerolog.ConsoleWriter{Out: os.Stderr, TimeFormat: time.TimeOnly}).With().Timestamp().Logger()

	r := http.NewServeMux()

	r.Handle("GET /healthz", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_ = json.NewEncoder(w).Encode(health{Status: "UP"})
	}))

	r.Handle("GET /", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html")
		w.WriteHeader(http.StatusOK)
		t, _ := template.New("index").Parse(templ)
		_ = t.Execute(w, map[string]string{"Namespace": os.Getenv("NAMESPACE")})
	}))

	srv := &http.Server{
		Handler:      r,
		Addr:         "0.0.0.0:8080",
		WriteTimeout: 15 * time.Second,
		ReadTimeout:  15 * time.Second,
	}

	log.Info().Msg("Starting server on port 8080...")
	log.Fatal().Err(srv.ListenAndServe())
}
