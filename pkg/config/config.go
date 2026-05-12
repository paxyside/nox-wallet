// Package config loads YAML + env-var configuration into a user
// struct via cleanenv. The app calls Load(WithConfigPaths(...)) at
// startup; nothing else here is consumed.
package config

import (
	"fmt"
	"os"

	"github.com/ilyakaznacheev/cleanenv"
)

// defaultConfigFiles lists the file names searched when WithConfigPaths
// isn't supplied. Order matters — the first file that exists wins.
func defaultConfigFiles() []string {
	return []string{
		"config.yaml",
		"config.yml",
		"config.local.yaml",
		"config.local.yml",
	}
}

// defaultEnvFiles lists .env-style files loaded before config parsing.
// Same first-match-wins rule as defaultConfigFiles.
func defaultEnvFiles() []string {
	return []string{".env", ".env.local"}
}

// Loader carries the resolved search paths so callers can build a
// custom loader once and reuse it. Most code paths call the
// package-level Load helper instead.
type Loader struct {
	configPaths []string
	envPaths    []string
}

// Option mutates the Loader. Use with NewLoader / Load.
type Option func(*Loader)

// WithConfigPaths overrides the default config file search list.
func WithConfigPaths(paths ...string) Option {
	return func(l *Loader) { l.configPaths = paths }
}

// NewLoader returns a Loader pre-seeded with the default file lists.
func NewLoader(opts ...Option) *Loader {
	l := &Loader{
		configPaths: defaultConfigFiles(),
		envPaths:    defaultEnvFiles(),
	}

	for _, opt := range opts {
		opt(l)
	}

	return l
}

// Load reads YAML and environment variables into cfg. Priority:
//  1. environment variables
//  2. the first existing .env file
//  3. the first existing YAML file
//  4. struct defaults declared via cleanenv tags
func (l *Loader) Load(cfg any) error {
	for _, envPath := range l.envPaths {
		if _, err := os.Stat(envPath); err == nil {
			if loadErr := loadEnvFile(envPath); loadErr != nil {
				return fmt.Errorf("config: failed to load %s: %w", envPath, loadErr)
			}

			break
		}
	}

	var configPath string
	for _, path := range l.configPaths {
		if _, err := os.Stat(path); err == nil {
			configPath = path
			break
		}
	}

	if configPath != "" {
		if err := cleanenv.ReadConfig(configPath, cfg); err != nil {
			return fmt.Errorf("config: failed to read %s: %w", configPath, err)
		}

		return nil
	}

	if err := cleanenv.ReadEnv(cfg); err != nil {
		return fmt.Errorf("config: failed to read env: %w", err)
	}

	return nil
}

// Load builds a one-shot Loader and reads cfg from disk + env.
func Load(cfg any, opts ...Option) error {
	return NewLoader(opts...).Load(cfg)
}

func loadEnvFile(path string) error {
	data, err := os.ReadFile(path)
	if err != nil {
		return err
	}

	return parseEnvFile(data)
}

// parseEnvFile reads .env-style content (KEY=VALUE per line, # comments,
// shell-style quoting) and exports each pair via os.Setenv. Existing
// env vars win over file values.
func parseEnvFile(data []byte) error {
	for _, line := range splitLines(data) {
		if len(line) == 0 || line[0] == '#' {
			continue
		}

		key, value, ok := parseEnvLine(line)
		if !ok {
			continue
		}

		if os.Getenv(key) == "" {
			_ = os.Setenv(key, value)
		}
	}

	return nil
}

func splitLines(data []byte) []string {
	var (
		lines []string
		line  []byte
	)

	for _, b := range data {
		if b == '\n' {
			lines = append(lines, string(line))
			line = nil
		} else if b != '\r' {
			line = append(line, b)
		}
	}

	if len(line) > 0 {
		lines = append(lines, string(line))
	}

	return lines
}

func parseEnvLine(line string) (string, string, bool) {
	for i := range len(line) {
		if line[i] != '=' {
			continue
		}

		k := trimSpace(line[:i])
		v := trimSpace(line[i+1:])

		if len(v) >= 2 {
			if (v[0] == '"' && v[len(v)-1] == '"') ||
				(v[0] == '\'' && v[len(v)-1] == '\'') {
				v = v[1 : len(v)-1]
			}
		}

		return k, v, k != ""
	}

	return "", "", false
}

func trimSpace(s string) string {
	start := 0
	end := len(s)

	for start < end && (s[start] == ' ' || s[start] == '\t') {
		start++
	}

	for end > start && (s[end-1] == ' ' || s[end-1] == '\t') {
		end--
	}

	return s[start:end]
}
