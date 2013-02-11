object @environment

if params[:short] == "true"
  extends "api/v2/environments/short"
elsif params[:long] == "true"
  extends "api/v2/environments/long"
else
  extends "api/v2/environments/medium"
end