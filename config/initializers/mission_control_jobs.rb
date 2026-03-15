MissionControl::Jobs.http_basic_auth_enabled = true
MissionControl::Jobs.http_basic_auth_username = ENV.fetch("JOBS_DASHBOARD_USERNAME", "admin")
MissionControl::Jobs.http_basic_auth_password = ENV.fetch("JOBS_DASHBOARD_PASSWORD", "secret")
