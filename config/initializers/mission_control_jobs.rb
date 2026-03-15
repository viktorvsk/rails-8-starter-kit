MissionControl::Jobs.http_basic_auth_enabled = true
MissionControl::Jobs.http_basic_auth_user = ENV.fetch("JOBS_DASHBOARD_USERNAME", "admin")
MissionControl::Jobs.http_basic_auth_password = ENV.fetch("JOBS_DASHBOARD_PASSWORD", "secret")
