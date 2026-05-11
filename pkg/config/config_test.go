package config

import (
	"os"
	"path/filepath"
	"testing"
	"time"
)

type TestConfig struct {
	App      TestApp      `yaml:"app"      env-prefix:"APP_"`
	Database TestDatabase `yaml:"database" env-prefix:"DB_"`
}

type TestApp struct {
	Name    string `yaml:"name"    env:"NAME"    env-default:"test-app"`
	Version string `yaml:"version" env:"VERSION" env-default:"1.0.0"`
	Debug   bool   `yaml:"debug"   env:"DEBUG"   env-default:"false"`
}

type TestDatabase struct {
	Host    string        `yaml:"host"    env:"HOST"    env-default:"localhost"`
	Port    int           `yaml:"port"    env:"PORT"    env-default:"5432"`
	Timeout time.Duration `yaml:"timeout" env:"TIMEOUT" env-default:"30s"`
}

func TestLoadDefaults(t *testing.T) {
	var cfg TestConfig

	// Clear any existing env vars
	_ = os.Unsetenv("APP_NAME")
	_ = os.Unsetenv("APP_VERSION")
	_ = os.Unsetenv("DB_HOST")

	err := Load(&cfg)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if cfg.App.Name != "test-app" {
		t.Errorf("expected App.Name = test-app, got %s", cfg.App.Name)
	}

	if cfg.App.Version == "" {
		t.Error("App.Version should not be empty")
	}

	if cfg.Database.Host != "localhost" {
		t.Errorf("expected Database.Host = localhost, got %s", cfg.Database.Host)
	}

	if cfg.Database.Port != 5432 {
		t.Errorf("expected Database.Port = 5432, got %d", cfg.Database.Port)
	}

	if cfg.Database.Timeout != 30*time.Second {
		t.Errorf("expected Database.Timeout = 30s, got %v", cfg.Database.Timeout)
	}
}

func TestLoadFromEnv(t *testing.T) {
	// Set env vars
	t.Setenv("APP_NAME", "my-service")
	t.Setenv("APP_DEBUG", "true")
	t.Setenv("DB_HOST", "postgres.local")
	t.Setenv("DB_PORT", "5433")

	defer func() {
		_ = os.Unsetenv("APP_NAME")
		_ = os.Unsetenv("APP_DEBUG")
		_ = os.Unsetenv("DB_HOST")
		_ = os.Unsetenv("DB_PORT")
	}()

	var cfg TestConfig

	err := Load(&cfg)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if cfg.App.Name != "my-service" {
		t.Errorf("expected App.Name = my-service, got %s", cfg.App.Name)
	}

	if !cfg.App.Debug {
		t.Errorf("expected App.Debug = true")
	}

	if cfg.Database.Host != "postgres.local" {
		t.Errorf("expected Database.Host = postgres.local, got %s", cfg.Database.Host)
	}

	if cfg.Database.Port != 5433 {
		t.Errorf("expected Database.Port = 5433, got %d", cfg.Database.Port)
	}
}

func TestLoadFromYAML(t *testing.T) {
	// Create temp config file
	dir := t.TempDir()
	configPath := filepath.Join(dir, "config.yaml")

	content := `
app:
  name: yaml-service
  version: 2.0.0
  debug: true
database:
  host: db.example.com
  port: 5434
  timeout: 60s
`
	if err := os.WriteFile(configPath, []byte(content), 0o644); err != nil {
		t.Fatalf("failed to write config file: %v", err)
	}

	// Clear env vars
	_ = os.Unsetenv("APP_NAME")
	_ = os.Unsetenv("DB_HOST")

	var cfg TestConfig

	err := Load(&cfg, WithConfigPaths(configPath))
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if cfg.App.Name != "yaml-service" {
		t.Errorf("expected App.Name = yaml-service, got %s", cfg.App.Name)
	}

	if cfg.App.Version != "2.0.0" {
		t.Errorf("expected App.Version = 2.0.0, got %s", cfg.App.Version)
	}

	if cfg.Database.Host != "db.example.com" {
		t.Errorf("expected Database.Host = db.example.com, got %s", cfg.Database.Host)
	}

	if cfg.Database.Timeout != 60*time.Second {
		t.Errorf("expected Database.Timeout = 60s, got %v", cfg.Database.Timeout)
	}
}

func TestEnvOverridesYAML(t *testing.T) {
	// Create temp config file
	dir := t.TempDir()
	configPath := filepath.Join(dir, "config.yaml")

	content := `
app:
  name: yaml-service
database:
  host: yaml-host
`
	if err := os.WriteFile(configPath, []byte(content), 0o644); err != nil {
		t.Fatalf("failed to write config file: %v", err)
	}

	// Set env var to override
	t.Setenv("APP_NAME", "env-service")

	defer os.Unsetenv("APP_NAME")

	var cfg TestConfig

	err := Load(&cfg, WithConfigPaths(configPath))
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	// Env should override YAML
	if cfg.App.Name != "env-service" {
		t.Errorf("expected App.Name = env-service (env override), got %s", cfg.App.Name)
	}

	// YAML value should be used where no env
	if cfg.Database.Host != "yaml-host" {
		t.Errorf("expected Database.Host = yaml-host, got %s", cfg.Database.Host)
	}
}

func TestParseEnvLine(t *testing.T) {
	tests := []struct {
		line    string
		wantKey string
		wantVal string
		wantOK  bool
	}{
		{"KEY=value", "KEY", "value", true},
		{"KEY=", "KEY", "", true},
		{"KEY=value with spaces", "KEY", "value with spaces", true},
		{`KEY="quoted value"`, "KEY", "quoted value", true},
		{`KEY='single quoted'`, "KEY", "single quoted", true},
		{"  KEY  =  value  ", "KEY", "value", true},
		{"# comment", "", "", false},
		{"", "", "", false},
		{"NOEQUALS", "", "", false},
	}

	for _, tt := range tests {
		key, val, ok := parseEnvLine(tt.line)
		if ok != tt.wantOK {
			t.Errorf("parseEnvLine(%q): ok = %v, want %v", tt.line, ok, tt.wantOK)
		}

		if key != tt.wantKey {
			t.Errorf("parseEnvLine(%q): key = %q, want %q", tt.line, key, tt.wantKey)
		}

		if val != tt.wantVal {
			t.Errorf("parseEnvLine(%q): val = %q, want %q", tt.line, val, tt.wantVal)
		}
	}
}
