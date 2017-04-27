autostash PROJECT_AUTHOR="`!v len($SELF_FULL_NAME) ? $SELF_FULL_NAME : ''`"
autostash PROJECT_EMAIL="`!v len($SELF_NOREPLY_EMAIL) ? $SELF_NOREPLY_EMAIL : ''`"
autostash PROJECT_GITHUB_USERNAME="`!v len($SELF_GITHUB_USERNAME) ? $SELF_GITHUB_USERNAME : ''`"
autostash PROJECT_NAME="${1:App Name}"
autostash PROJECT_INIT_VERSION="`!v len($SELF_INIT_VERSION) ? $SELF_INIT_VERSION : '0.1.0'`"
autostash PROJECT_BRIEF="${2:Enter project description}"
autostash PROJECT_SLUG="$(projID $PROJECT_NAME)"
autostash PROJECT_PACKAGE="$(pkgID $PROJECT_NAME)"
autostash PROJECT_VC_DIt="`!v len($SELF_VERSION_CONTROL_DIR) ? $SELF_VERSION_CONTROL_DIR : '.git'`"
autostash PROJECT_MAIN=""
autostash PROJECT_LICENSE_SLUG="${3:license}"
autostash PROJECT_LICENSE_NAME="`!v len($DEFAULT_LICENSE_NAME) ? $DEFAULT_LICENSE_NAME : 'Copyright Act of 1976, Pub.L. 94-553, 90 Stat. 2541, Section 401(a) (October 19, 1976)'`"
autostash PROJECT_LICENSE_BRIEF="`!v len($DEFAULT_LICENSE_BRIEF) ? $DEFAULT_LICENSE_BRIEF : 'All rights reserved. This body of work or any portion thereof may not be reproduced or used in any manner whatsoever without the express written permission of the author.'`"