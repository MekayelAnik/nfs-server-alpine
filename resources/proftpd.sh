#!/bin/bash
/usr/bin/banner.sh
# Show Conatiner Start Time
# Check if Username & Password is set for Each FTP share
# Create FTP User and assign Password, UID & GID from Environment variables for Multiple Users
if [[ -z "${ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP}" ]]; then
	ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP='false'
fi
if [[ -z "${FTP_SHARE_COMMON_GID}" ]]; then
	FTP_SHARE_COMMON_GID='2121'
fi
if [[ -z "${FTP_SHARE_COMMON_GROUP_NAME}" ]]; then
	FTP_SHARE_COMMON_GROUP_NAME='ftp-common'
fi
######	Function for setting up Password for each FTP Share	######
set-password() {
	echo "${!FTP_SHARE}:${!FTP_PASS}" | chpasswd
}
######	Function for creating Shares with no Given UID & GID	######
no-uid-gid() {
	FTP_UID=$((1100 + i))
	if getent group ${FTP_UID} >/dev/null 2>&1; then
		FTP_UID=$((456 + FTP_UID))
	fi
	adduser -D -u "${FTP_UID}" -s /bin/sh -h /data/"${!FTP_SHARE}" "${!FTP_SHARE}"
	set-password
	chown -cR "${FTP_UID}":"${FTP_UID}" /data/"${!FTP_SHARE}"
}
ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP=$(echo "${ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP}" | tr '[:upper:]' '[:lower:]')
if [[ "${ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP}" == 'true' ]] || [[ "${ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP}" == 'enabled' ]] || [[ "${ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP}" == 'enable' ]] || [[ "${ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP}" == 'yes' ]] || [[ "${ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP}" == 'ok' ]] || [[ "${ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP}" == 'y' ]] || [[ "${ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP}" == 'ya' ]] || [[ "${ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP}" == '1' ]]; then
	ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP='true'
fi
######	Check if NUMBER_OF_SHARES is Valid	######
if [[ "${NUMBER_OF_SHARES}" =~ ^[0-9]+$ ]] && [[ "${NUMBER_OF_SHARES}" -ge 1 ]] && [[ "${NUMBER_OF_SHARES}" -le 2147482647 ]]; then
	echo "You have set NUMBER_OF_SHARES to ${NUMBER_OF_SHARES}. Creating ${NUMBER_OF_SHARES} FTP Shares with provided USERNAME(s) & PASSWORD(s)..."
	for ((i = 1; i <= "${NUMBER_OF_SHARES}"; i++)); do
		FTP_SHARE=FTP_SHARE_${i}
		FTP_PASS=FTP_PASSWORD_${i}
		if [[ -z "${!FTP_SHARE}" ]] || [[ -z "${!FTP_PASS}" ]]; then
			if [[ -z "${!FTP_SHARE}" ]]; then
				echo "No value is set in ${FTP_SHARE}!"
			fi
			if [[ -z "${!FTP_PASS}" ]]; then
				echo "No value is set in ${FTP_PASS}!"
			fi
			echo "So you MUST give input in:"
			if [[ -z "${!FTP_SHARE}" ]]; then
				echo "${FTP_SHARE}!"
			fi
			if [[ -z "${!FTP_PASS}" ]]; then
				echo "${FTP_PASS}!"
			fi
			echo "Exitting..."
			exit 1
		fi
		if id "${!FTP_SHARE}" >/dev/null 2>&1; then
			:
		else
			FTP_UID=FTP_SHARE_${i}_PUID
			FTP_GID=FTP_SHARE_${i}_PGID
			FTP_CHMOD=FTP_SHARE_${i}_CHMOD
			if [[ "$ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP" == 'true' ]]; then
				######	If the Share is not under a COMMON FTP GROUP	######
				if [[ -n "${FTP_SHARE_COMMON_GID}" ]]; then
					if [[ "${FTP_SHARE_COMMON_GID}" =~ ^[0-9]+$ ]]; then
						if [[ "${FTP_SHARE_COMMON_GID}" -ge 1000 ]] && [[ "${FTP_SHARE_COMMON_GID}" -le 2147483647 ]]; then
							if getent group "${FTP_SHARE_COMMON_GID}" >/dev/null 2>&1; then
								:
							else
								addgroup --gid "${FTP_SHARE_COMMON_GID}" "${FTP_SHARE_COMMON_GROUP_NAME}"
							fi
							if [[ -z "${!FTP_UID}" ]]; then
								FTP_UID=$((1100 + i))
								adduser -D -u "${FTP_UID}" -s /bin/sh -h /data/"${!FTP_SHARE}" "${!FTP_SHARE}"
								set-password
								usermod -aG "${FTP_SHARE_COMMON_GID}" "${!FTP_SHARE}"
								chown -cR "${FTP_UID}":"${FTP_SHARE_COMMON_GID}" /data/"${!FTP_SHARE}"
							else
								if [[ "${!FTP_UID}" =~ ^[0-9]+$ ]]; then
									if [[ "${!FTP_UID}" -ge 1000 ]] && [[ "${!FTP_UID}" -le 2147483647 ]]; then
										adduser -D -u "${!FTP_UID}" -s /bin/sh -h /data/"${!FTP_SHARE}" "${!FTP_SHARE}"
										set-password
										usermod -aG "${FTP_SHARE_COMMON_GID}" "${!FTP_SHARE}"
										chown -cR "${!FTP_UID}":"${FTP_SHARE_COMMON_GID}" /data/"${!FTP_SHARE}"
									else
										echo "The PUID for ${!FTP_SHARE} is out of optimal range. Set unique PUID value between 1000 to 2147483647 in $FTP_UID. Otherwise skipping creation of ${!FTP_SHARE}..."
									fi
								else
									echo "You have to set integer value in FTP_SHARE_COMMON_GID. Otherwise skipping the creation of ${!FTP_SHARE}..."
								fi
							fi
						else
							echo "The GID for ${FTP_SHARE_COMMON_GROUP_NAME} is set to ${FTP_SHARE_COMMON_GID}, which is out of optimal range. Set unique GUID value between 1000 to 2147483647 in FTP_SHARE_COMMON_GID. Otherwise Exitting..."
							exit 1
						fi
					else
						echo "You have to set integer value in FTP_SHARE_COMMON_GID. Exitting..."
						exit 1
					fi
				else
					echo "You have set value TRUE in ALL_FTP_SHARES_UNDER_SINGLE_COMMON_GROUP but didn't set integer value in FTP_SHARE_COMMON_GID. Otherwise Exitting..."
					exit 1
				fi
			######	If the Share is not under a COMMON FTP GROUP	######
			else
				######	Creating FTP Shares with no Given UID & GID	######
				if [[ -z "${!FTP_UID}" ]] && [[ -z "${!FTP_GID}" ]]; then
					FTP_UID=$((1100 + i))
					no-uid-gid
				######	Creating FTP Shares with Given UID & but no Given GID	######
				elif [[ -n "${!FTP_UID}" ]] && [[ -z "${!FTP_GID}" ]]; then
					if [[ "${!FTP_UID}" =~ ^[0-9]+$ ]]; then
						if [[ "${!FTP_UID}" -ge 1000 ]] && [[ "${!FTP_UID}" -le 2147483647 ]]; then
							if getent passwd ${!FTP_UID} >/dev/null 2>&1; then
								echo "User with same PUID already exists. Creating user with different PUID"
								no-uid-gid
							else
								adduser -D -u "${!FTP_UID}" -s /bin/sh -h /data/"${!FTP_SHARE}" "${!FTP_SHARE}"
								set-password
							fi
						else
							echo "The PUID for ${!FTP_SHARE} is set to ${!FTP_UID}, which is out of optimal range. Set unique PUID value between 1000 to 2147483647 in $FTP_UID. Otherwise skipping creation of ${!FTP_SHARE}..."
						fi
					else
						echo "UID of ${!FTP_SHARE} is not integer. Change the value of ${FTP_UID} to a integer one. Otherwise skipping creation of ${!FTP_SHARE}..."
					fi
				######	Creating FTP Shares with no Given UID &  but Given GID	######
				elif [[ -z "${!FTP_UID}" ]] && [[ -n "${!FTP_GID}" ]]; then
					if [[ "${!FTP_GID}" =~ ^[0-9]+$ ]]; then
						if [[ "${!FTP_GID}" -ge 1000 ]] && [[ "${!FTP_GID}" -le 2147483647 ]]; then
							if getent passwd ${!FTP_GID} >/dev/null 2>&1; then
								FTP_UID=$((1100 + i))
							else
								FTP_UID="${!FTP_GID}"
							fi
							if getent group "${FTP_UID}" >/dev/null 2>&1; then
								FTP_UID=$((456 + FTP_UID))
							fi
							adduser -D -u "${FTP_UID}" -s /bin/sh -h /data/"${!FTP_SHARE}" "${!FTP_SHARE}"
							set-password
							if getent group "${!FTP_GID}" >/dev/null 2>&1; then
								:
							else
								if [[ "${FTP_UID}" != "${!FTP_GID}" ]]; then
									addgroup --gid "${!FTP_GID}" "${FTP_GROUP_NAME}${!FTP_GID}"
								fi
							fi
							if getent group ${!FTP_GID} >/dev/null 2>&1; then
								usermod -aG "${!FTP_GID}" "${!FTP_SHARE}"
							else
								echo "Group with GUID=${!FTP_GID} doesn't Exist. Hence ${!FTP_SHARE} share is not added to Group with GUID=${!FTP_GID}"
							fi
							chown -cR "${FTP_UID}":"${!FTP_GID}" /data/"${!FTP_SHARE}"
						else
							echo "The GUID for ${!FTP_SHARE} is set to ${!FTP_GID}, which is out of optimal range. Set unique GUID value between 1000 to 2147483647 in $FTP_GID. Otherwise Skipping group creation..."
						fi
					else
						echo "Set integer Value in ${FTP_GID}. Otherwise skipping creation of Group ${!FTP_GID}"
						no-uid-gid
					fi
				######	Creating FTP Shares with Given UID & Given GID	######
				elif [[ -n "${!FTP_UID}" ]] && [[ -n "${!FTP_GID}" ]]; then
					if [[ "${!FTP_UID}" =~ ^[0-9]+$ ]]; then
						if [[ "${!FTP_UID}" -ge 1000 ]] && [[ "${!FTP_UID}" -le 2147483647 ]]; then
							if [[ "${!FTP_UID}" != "${!FTP_GID}" ]]; then
								if [[ "${!FTP_GID}" =~ ^[0-9]+$ ]]; then
									if [[ "${!FTP_GID}" -ge 1000 ]] && [[ "${!FTP_GID}" -le 2147483647 ]]; then
										if getent group "${!FTP_GID}" >/dev/null 2>&1; then
											echo "Group already exists of GUID=${!FTP_GID}. So skipping this group creation..."
										else
											addgroup --gid "${!FTP_GID}" "${FTP_GROUP_NAME}${!FTP_GID}"
										fi
									else
										echo "The GUID for ${!FTP_SHARE} is set to ${!FTP_GID}, which is out of optimal range. Set unique GUID value between 1000 to 2147483647 in $FTP_GID. Otherwise Skipping Group creation..."
									fi
								else
									echo "GUID of ${!FTP_SHARE} is not integer. Skipping Group Creation..."
								fi
							fi
							if getent passwd ${!FTP_UID} >/dev/null 2>&1; then
								echo "Share with PUID=${!FTP_UID} already exists."
								FTP_UID=$((1100 + i))
								if getent group "${FTP_UID}" >/dev/null 2>&1; then
									FTP_UID=$((456 + FTP_UID))
								fi
								echo "Instead creating FTP Share ${!FTP_SHARE} with UID=${FTP_UID} and assigning it to the PGID=${!FTP_GID}"
								adduser -D -u "${FTP_UID}" -s /bin/sh -h /data/"${!FTP_SHARE}" "${!FTP_SHARE}"
								set-password
								if [[ "${FTP_UID}" != "${!FTP_GID}" ]] && [[ "${!FTP_GID}" =~ ^[0-9]+$ ]]; then
									usermod -aG "${!FTP_GID}" "${!FTP_SHARE}"
								fi
								if [[ "${!FTP_GID}" =~ ^[0-9]+$ ]]; then
									chown -cR "${FTP_UID}":"${!FTP_GID}" /data/"${!FTP_SHARE}"
								fi
							else
								adduser -D -u "${!FTP_UID}" -s /bin/sh -h /data/"${!FTP_SHARE}" "${!FTP_SHARE}"
								set-password
								if [[ "${!FTP_UID}" != "${!FTP_GID}" ]]; then
									if getent group ${!FTP_GID} >/dev/null 2>&1 && [[ "${!FTP_GID}" =~ ^[0-9]+$ ]]; then
										usermod -aG "${!FTP_GID}" "${!FTP_SHARE}"
									elif [[ "${!FTP_GID}" =~ ^[0-9]+$ ]]; then
										echo "Group with GUID=${!FTP_GID} doesn't Exist. Hence ${!FTP_SHARE} share is not added to Group with GUID=${!FTP_GID}"
									elif ! [[ "${!FTP_GID}" =~ ^[0-9]+$ ]]; then
										echo "GUID of ${!FTP_SHARE} is not an integer value. Hence ${!FTP_SHARE} share is not added to Group with GUID=${!FTP_GID}"
									fi
								fi
								if [[ "${!FTP_GID}" =~ ^[0-9]+$ ]]; then
									chown -cR "${!FTP_UID}":"${!FTP_GID}" /data/"${!FTP_SHARE}"
								fi
							fi
						else
							echo "The PUID for ${!FTP_SHARE} is set to ${!FTP_UID}, which out of optimal range. Set unique PUID value between 1000 to 2147483647 in $FTP_UID. Otherwise skipping creation of ${!FTP_SHARE}..."
						fi
					else
						echo "UID of ${!FTP_SHARE} is not integer. Change the value of ${FTP_UID} to a integer one. Otherwise skipping creation of ${!FTP_SHARE}..."
					fi
				fi
			fi
			######	CHMOD an FTP Share if the is a valid value	######
			if [[ -n "${!FTP_CHMOD}" ]] && [[ "${!FTP_CHMOD}" =~ ^[0-9]+$ ]] && [[ "${!FTP_CHMOD}" -ge 0 ]] && [[ "${!FTP_CHMOD}" -le 0777 ]]; then
				chmod -cR "${!FTP_CHMOD}" /data/"${!FTP_SHARE}"
			fi
		fi
	done
else
	echo "NUMBER_OF_SHARES must be NON-EMPTY and it's value has to be an integer Greater than 0 and less than 2147482647. Otherwise No Share will be created. Exitting..."
	exit 1
fi
echo -e "Include /etc/proftpd/conf.d/*.conf\n
DefaultServer           on\n
Group                   ftp\n
User                    ftp\n
Port                    $FTP_PORT\n
ServerType              standalone\n
UseIPv6                 off\n
WtmpLog                 off\n
RootLogin               off\n
UseReverseDNS           off\n
AllowOverwrite          $ALLOW_OVERWRITE\n
MaxInstances            $MAX_INSTANCES\n
MaxClients              $MAX_CLIENTS\n
PassivePorts            4559 4564\n
ServerName              $SERVER_NAME\n
TimesGMT                $TIMES_GMT\n
Umask                   $LOCAL_UMASK\n
DefaultRoot             $LOCAL_ROOT\n
TimeoutIdle             $TIMEOUT_IDLE\n
TimeoutNoTransfer       $TIMEOUT_NO_TRANSFER\n
TimeoutStalled          $TIMEOUT_STALLED\n
<Limit WRITE>\n
  AllowAll\n
</Limit>" >/etc/proftpd/proftpd.conf
exec "$@"