generate_nezha() {
  cat > nezha.sh << EOF
#!/usr/bin/env bash

# 哪吒的4个参数
NEZHA_SERVER="$NEZHA_SERVER"
NEZHA_PORT="$NEZHA_PORT"
NEZHA_KEY="$NEZHA_KEY"
NEZHA_TLS="$NEZHA_TLS"

# 检测是否已运行
check_run() {
  [[ \$(pgrep -laf nezha-agent) ]] && echo "哪吒客户端正在运行中!" && exit
}

# 三个变量不全则不安装哪吒客户端
check_variable() {
  [[ -z "\${NEZHA_SERVER}" || -z "\${NEZHA_PORT}" || -z "\${NEZHA_KEY}" ]] && exit
}

# 下载最新版本 Nezha Agent
download_agent() {
  if [ ! -e nezha-agent ]; then
    URL=\$(wget -qO- -4 "https://api.github.com/repos/naiba/nezha/releases/latest" | grep -o "https.*linux_amd64.zip")
    wget -t 2 -T 10 -N \${URL}
    unzip -qod ./ nezha-agent_linux_amd64.zip && rm -f nezha-agent_linux_amd64.zip
  fi
}

check_run
check_variable
download_agent
EOF
}

generate_pm2_file() {
  TLS=${NEZHA_TLS:+'--tls'}
  cat > ecosystem.config.js << EOF
module.exports = {
  "apps":[
      {
EOF

  [[ -n "${NEZHA_SERVER}" && -n "${NEZHA_PORT}" && -n "${NEZHA_KEY}" ]] && cat >> ecosystem.config.js << EOF
      },
      {
          "name":"nezha",
          "script":"nezha-agent",
          "args":"-s ${NEZHA_SERVER}:${NEZHA_PORT} -p ${NEZHA_KEY} ${TLS}"
EOF

  cat >> ecosystem.config.js << EOF
      }
  ]
}
EOF
}

generate_nezha
generate_pm2_file

[ -e nezha.sh ] && bash nezha.sh
[ -e ecosystem.config.js ] && pm2 start ecosystem.config.js
wait
