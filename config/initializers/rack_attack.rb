# typed: false
# frozen_string_literal: true

# Rack::Attack configuration for rate limiting.
# Uses Redis as shared store (important since web containers scale to 3 replicas).

# ── Store ────────────────────────────────────────────────────────
redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/1")
Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: redis_url)

# Disable in test/e2e unless explicitly enabled
unless ENV["ENABLE_RACK_ATTACK"] == "1"
  Rack::Attack.enabled = false if Rails.env.test? || Rails.env.e2e?
end

# ── Defaults ─────────────────────────────────────────────────────
DEFAULT_UI_RPH = ENV.fetch("RACK_ATTACK_UI_RPH", 5000).to_i
DEFAULT_API_RPH = ENV.fetch("RACK_ATTACK_API_RPH", 5000).to_i

# ── Safelist ─────────────────────────────────────────────────────

Rack::Attack.safelist("health-check") do |req|
  req.path == "/up"
end

# ── Throttle: UI (by IP) ─────────────────────────────────────────

Rack::Attack.throttle("ui/ip", limit: DEFAULT_UI_RPH, period: 3600) do |req|
  next if req.path.start_with?("/api/", "/api")

  req.ip
end

# ── Throttle: API (by IP) ────────────────────────────────────────

Rack::Attack.throttle("api/ip", limit: DEFAULT_API_RPH, period: 3600) do |req|
  next unless req.path.start_with?("/api/")

  req.ip
end

# ── Throttled Response ───────────────────────────────────────────

Rack::Attack.throttled_responder = lambda { |req|
  matched = req.env["rack.attack.match_data"] || {}
  retry_after = (matched[:period] || 60) - (matched[:epoch_time] % (matched[:period] || 60))

  headers = {
    "Content-Type" => "application/json",
    "Retry-After" => retry_after.to_s,
  }
  body = { error: { code: "RATE_LIMITED", message: "Rate limit exceeded. Retry after #{retry_after} seconds." } }.to_json
  [429, headers, [body]]
}
