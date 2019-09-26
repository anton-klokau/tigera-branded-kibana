FROM alpine:3.7 as builder
COPY kibana /kibana
RUN apk add --no-cache zip
RUN zip -r /tigera_style.zip kibana

FROM docker.elastic.co/kibana/kibana:7.3.2

# custom throbber
RUN sed -i 's/Loading Kibana/Loading Tigera/g' /usr/share/kibana/src/legacy/ui/ui_render/views/ui_app.pug
RUN sed -i 's/image\/svg+xml.*");/image\/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB2ZXJzaW9uPSIxLjEiIGlkPSJMYXllcl8xIiB4bWw6c3BhY2U9InByZXNlcnZlIiB2aWV3Qm94PSIwIDAgMjQwIDE2NiI+PHN0eWxlIHR5cGU9InRleHQvY3NzIj4uc3Qwe2ZpbGw6I0ZGOUUxNjt9LnN0MXtmaWxsOiNGRkZGRkY7fTwvc3R5bGU+PHRpdGxlPkFzc2V0IDE8L3RpdGxlPjxnIGlkPSJMYXllcl8yXzFfIj48ZyBpZD0iTGF5ZXJfMS0yIj48cGF0aCBjbGFzcz0ic3QwIiBkPSJNMjI2LDk2LjhjLTQuMiw1LjMtOS42LDkuNy0xNS42LDEyLjhjMy4yLTQuMSw0LjUtOS4xLDQuNC0xNC43Yy0yMC40LDAtMzYuNSwxMy4zLTI4LjksMzljNC4zLTAuMyw2LjgtMy4zLDkuMS02LjVjMC4yLDMuNy0wLjcsNy43LTMuNSwxMi40bDEuOCw0LjJjLTUuMywzLjgtMTMsMTEtMTkuMiw4LjljLTE2LjUtMTkuMy00Mi4yLTI0LjYtNzUuOS00YzIuNC01LjksNC0xMC4zLDkuMy0xNWMtNi4yLTAuMi0xNy44LDEuNC0yNi44LDYuNGMwLjItMjQuNyw0LTQ5LjMsMTEuMy03Mi45Qzc2LDk1LDY4LjIsMTI3LjIsNjAuMiwxNjZjLTguNS0zNi43LTE0LjktNjIuNC05LjEtMTA0LjRjLTE3LDMtMzYsMTQuMy01MS4xLDIzLjhjMTguMi0yNC4yLDU3LjQtNTAuMiw3NC41LTU1LjJjLTguMywxMy41LTEzLjYsMzIuMS0xNC44LDQ3LjNsNy43LTAuN2MtMy4xLDYuOC02LjMsMjIuNS02LjMsMzUuN2MyLjMtMTQsOS4zLTMyLjYsMTYuNC00NC4zTDY4LjEsNjljNS4zLTE4LjksMTgtMzcuNSwyOS00My44YzQuOC0xLjUsOS43LTIuMiwxNC43LTEuOWMtMS4zLDcuOS03LjcsNDguMS00LjUsNjYuN2MwLjEtMTkuOSw5LjYtNzUuNiwxNy4zLTg5LjlDMTM2LjksMTEsMTM5LDE2LDE0My42LDI1LjdjMjQuMywxLjMsNDMuMiwxMi44LDYwLjksMjYuNGMtMC40LDEuNC0xLjQsMi41LTIuOCwzLjFjNC43LDEuNywxNi4zLDguMywyMC44LDEyLjFjNS45LDUsMTMuNCwxMS42LDE3LjEsMTZsLTcsMTFsLTMuMi05LjVsNi40LTEuMWwtOC41LTAuMWwzLjUsMTEuNkwyMjYsOTYuOHogTTE5MS43LDY3LjZsLTYuNS04LjJsLTE3LjYtNS4xbDEwLjMsOC41bDYuMS0wLjNMMTkxLjcsNjcuNnoiLz48L2c+PC9nPjwvc3ZnPg==");/g' /usr/share/kibana/src/legacy/ui/ui_render/views/ui_app.pug /usr/share/kibana/src/legacy/ui/ui_render/views/chrome.pug

# custom HTML title information
RUN sed -i 's/title Kibana/title Tigera/g' /usr/share/kibana/src/legacy/ui/ui_render/views/chrome.pug

# custom plugin css
COPY --from=builder /tigera_style.zip /
RUN sed -i 's/reverse()/reverse(),`${regularBundlePath}\/tigera_style.style.css`/g' /usr/share/kibana/src/legacy/ui/ui_render/ui_render_mixin.js

# Modify logoKibana in vendorsDynamicDLL to be empty. Custom icon will be set as background-image in gradiant_style plugin css
RUN sed -i 's@var logoKibana=function.*logoKibana.defaultProps=@var logoKibana=function logoKibana(props){return _react.default.createElement("svg",props,_react.default.createElement("g",{fill:"none",fillRule:"evenodd"}))};logoKibana.defaultProps=@g' /usr/share/kibana/built_assets/dlls/vendors.bundle.dll.js

RUN bin/kibana-plugin install file:///tigera_style.zip
RUN bin/kibana --env.name=production --logging.json=false --optimize


