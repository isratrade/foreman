collection @environments

if params[:medium] == "true"
  extends "api/v2/environments/medium"
elsif params[:long] == "true"
  extends "api/v2/environments/long"
else
  extends "api/v2/environments/short"
end