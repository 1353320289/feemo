/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
导出路径
#===================================================
# 系统要求：CentOS 7/8、Debian/ubuntu、oraclelinux
#描述：BBR+BBRplus+Lotserver
# 版本：100.0.2.7
#===================================================

# 红色='\033[0;31m'
# 绿色='\033[0;32m'
# 黄色='\033[0;33m'
# 天蓝色='\033[0;36m'
# PLAIN='\033[0m'

sh_ver="100.0.2.7"
github="raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master"

imgurl=""
标题网址=""
github_network=1

Green_font_prefix="\033[32m"
Red_font_prefix="\033[31米"
字体颜色后缀="\033[0m"
信息=“${Green_font_prefix}[信息]${Font_color_suffix}”
错误=“${Red_font_prefix}[错误]${Font_color_suffix}”
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

如果 [ -f "/etc/sysctl.d/bbr.conf" ]; 那么
  rm -rf /etc/sysctl.d/bbr.conf
菲

# 检查当前用户是否为root用户
如果 [ “$EUID” -ne 0 ]; 那么
  echo "请使用root用户身份运行此脚本"
  出口
菲

# 检查github网络
check_github（）{
  # 检测域名的可访问性函数
  检查域（）{
    本地域=“$1”
    如果！curl --max-time 5 --head --silent --fail“$domain”> / dev / null;然后
      echo -e "${Error} 无法访问 $domain，请检查网络或者本地 DNS 或者访问频率过快而设定"
      github_network=0
    菲
  }

  # 检测所有域名的可访问性
  check_domain "https://raw.githubusercontent.com"
  check_domain“https://api.github.com”
  check_domain“https://github.com”

  如果 [ “$github_network” -eq 0 ]; 然后
    echo -e "${Error}github网络访问设置，将影响内核的安装以及脚本的检查更新，5秒后继续运行脚本"
    睡 5
  别的
    #所有护士访问，打印成功提示
    echo "${Green_font_prefix}github可访问${Font_color_suffix}，继续执行脚本..."
  菲
}

#检查题目
检查网址（）{
  本地网址=“$1”
  本地最大重试次数=3
  本地重试延迟=2

  如果 [[ -z "$url" ]]; 那么
    echo "错误：缺少URL参数！"
    出口 1
  菲

  本地重试=0
  本地响应代码=“”

  while [[ -z "$responseCode" && $retries -lt $maxRetries ]]; 执行
    响应代码 = $ (curl --max-time 6 -s -L -m 10 --connect-timeout 5 -o /dev/null -w "%{http_code}" "$url")

    如果 [[ -z "$responseCode" ]]; 那么
      ((重试++))
      睡眠$retryDelay
    菲
  完毕

  如果 [[ -n "$responseCode" && ("$responseCode" == "200" || "$responseCode" =~ ^3[0-9]{2}$) ]]; 然后
    echo "下载地址检查确定，继续！"
  别的
    echo "下载地址检查错误，退出！"
    出口 1
  菲
}

#cn处理github加速
检查_cn（）{
  #检查是否安装了jq命令，如果没有安装则进行安装
  如果 ! 命令 -v jq >/dev/null 2>&1; 那么
    如果命令 -v yum >/dev/null 2>&1; 则
      sudo yum install epel-release -y
      sudo yum 安装-y jq
    elif 命令 -v apt-get >/dev/null 2>&1; 然后
      sudo apt-get 更新
      sudo apt-get 安装-y jq
    别的
      echo "无法安装jq命令。请手动安装jq后再试。"
      出口 1
    菲
  菲

  # 获取当前IP地址，设置超时为3秒
  current_ip=$(curl -s --max-time 3 https://api.ipify.org)

  # 使用ip-api.com查询IP所在国家，设置超时为3秒
  响应=$（curl -s --max-time 3“http://ip-api.com/json/$current_ip”）

  #检查国家是否为中国
  国家=$（echo“$response”| jq -r'.countryCode'）
  如果 [[ "$country" == "CN" ]]; 那么
    本地后缀=（
      “https://gh.​​con.sh/”
      “https://gh-proxy.com/”
      “https://ghp.ci/”
      “https://gh.​​ml.cc/”
      “https://down.npee.cn/？”
      “https://mirror.ghproxy.com/”
      “https://ghps.cc/”
      “https://gh.​​api.99988866.xyz/”
      “https://git.886.be/”
      “https://hub.gitmirror.com/”
	  “https://pd.zwc365.com/”
      “https://gh.​​ddlc.top/”
      “https://slink.ltd/”
      “https://github.moeyy.xyz/”
      “https://ghproxy.crazypeace.workers.dev/”
	  “https://gh.​​h233.eu.org/”
    ）

    # 循环遍历每个后缀并测试组合的链接
    对于“${suffixes[@]}”中的后缀；执行
      # 组合后缀和原始链接
      combined_url="$后缀$1"

      # 使用curl -I获取头部信息，提取状态码
      本地 response_code=$(curl --max-time 2 -sL -w "%{http_code}" -I "$combined_url" | head -n 1 | awk'{print $2}')

      #查询响应码是否表示成功(2xx)
      如果 [[ $response_code -ge 200 && $response_code -lt 300 ]]; 然后
        回显“$combined_url”
        return 0 # 返回可用链接，结束函数
      菲
    完毕

  # 如果没有找到有效链接，则返回原始链接
  别的
    回显“$1”
    返回 1

  菲
}

#下载
下载文件（）{
  网址=“$1”
  文件名="$2"

  wget“$url”-O“$文件名”
  状态=$？

  如果 [ $status -eq 0 ]; 那么
    echo -e "\e[32m文件下载成功或已经是最新的。\e[0m"
  别的
    echo -e "\e[31m文件下载失败，退出状态码: $status\e[0m"
    出口 1
  菲
}

#检查值
检查空() {
  本地变量值=$1

  如果 [[ -z $var_value ]]; 那么
    echo "$var_value 是空值，退出！"
    出口 1
  菲
}

#检查磁盘空间
检查磁盘空间() {
    #检查是否存在bc命令
    如果 ! 命令 -v bc &> /dev/null; 那么
        echo "安装bc命令..."
        # 检查系统类型并安装相应的bc包
        如果 [ -f /etc/redhat-release ]; 那么
            yum 安装 -y bc
        elif [ -f /etc/debian_version ]; 然后
            apt-get 更新
            apt-get 安装 -y bc
        别的
            echo "无法确定系统类型，请手动安装 bc 命令。"
            返回 1
        菲
    菲

    # 获取当前磁盘剩余空间
    可用空间=$（df -h / | awk'NR==2 {打印$4}'）

    # 删除单位字符，例如"GB"，剩下剩余空间转换为数字
    可用空间 = $（echo $可用空间 | sed's/G//'）

    # 如果剩余空间小于等于0，则输出警告信息
    如果 [ $(echo "$available_space <= 0" | bc) -eq 1 ]; 然后
        echo "警告：磁盘空间已用尽，请勿重启，先清理空间。建议先卸载刚才安装的内核来释放空间，仅供参考。"
    别的
        echo "当前磁盘剩余空间：$available_space GB"
    菲
}

#安装BBR内核
安装bbr（）{
  内核版本=“5.9.6”
  位=$(uname -m)
  rm -rf bbr
  mkdir bbr && cd bbr || 退出

  如果 [[ “${OS_type}” == “CentOS” ]]; 然后
    如果 [[ ${version} == "7" ]]; 然后
      如果 [[ ${bit} == "x86_64" ]]; 然后
        echo -e "如果下载地址错误，可能当前正在更新，超过半天还是错误请反馈，大陆手机解决污染问题"
        #github_ver=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep ${github_tag} | head -n 1 | awk -F '"' '{打印 $4}' | awk -F '[/]' '{打印 $8}' | awk -F '[_]' '{打印 $3}')
        github_tag=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep 'Centos_Kernel' | grep '_latest_bbr_' | head -n 1 | awk -F '"' '{打印 $4}' | awk -F '[/]' '{打印 $8}')
        github_ver=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep ${github_tag} | grep 'rpm' | grep 'headers' | awk -F '"' '{打印 $4}' | awk -F '[/]' '{打印 $9}' | awk -F '[-]' '{打印 $3}')
        check_empty $github_ver
        echo -e "获取的版本号为:${Green_font_prefix}${github_ver}${Font_color_suffix}"
        内核版本=$github_ver
        删除内核头
        headurl=$(curl -s'https://api.github.com/repos/ylx2016/kernel/releases'|grep ${github_tag} |grep'rpm'|grep'headers'|awk -F'"''{print $4}')
        imgurl=$(curl -s'https://api.github.com/repos/ylx2016/kernel/releases'|grep ${github_tag}|grep'rpm'|grep -v'headers'|grep -v'devel'|awk -F'"''{print $4}')
        #headurl=https://github.com/ylx2016/kernel/releases/download/$github_tag/kernel-headers-${github_ver}-1.x86_64.rpm
        #imgurl=https://github.com/ylx2016/kernel/releases/download/$github_tag/kernel-${github_ver}-1.x86_64.rpm

        check_empty $imgurl
        headurl=$(check_cn $headurl)
        imgurl=$(check_cn $imgurl)

        download_file $headurl kernel-headers-c7.rpm
        下载文件$imgurl kernel-c7.rpm
        yum 安装 -y 内核-c7.rpm
        yum 安装 -y 内核头文件-c7.rpm
      别的
        echo -e "${Error} 不支持x86_64以外的系统！" && 出口 1
      菲
    菲

  elif [[ “${OS_type}” == “Debian” ]]; 然后
    如果 [[ ${bit} == "x86_64" ]]; 然后
      echo -e "如果下载地址错误，可能当前正在更新，超过半天还是错误请反馈，大陆手机解决污染问题"
      github_tag=$(curl -s'https://api.github.com/repos/ylx2016/kernel/releases'|grep'Debian_Kernel'|grep'_latest_bbr_'|head -n 1|awk -F'“''{打印 $4}'|awk -F'[/]''{打印 $8}')
      github_ver=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep ${github_tag} | grep 'deb' | grep 'headers' | awk -F '"' '{打印 $4}' | awk -F '[/]' '{打印 $9}' | awk -F '[-]' '{打印 $3}' | awk -F '[_]' '{打印 $1}')
      check_empty $github_ver
      echo -e "获取的版本号为:${Green_font_prefix}${github_ver}${Font_color_suffix}"
      内核版本=$github_ver
      删除内核头
      headurl = $（curl -s'https://api.github.com/repos/ylx2016/kernel/releases'|grep ${github_tag} |grep'deb'|grep'headers'|awk -F'“''{print $4}'）
      imgurl=$(curl -s'https://api.github.com/repos/ylx2016/kernel/releases'|grep ${github_tag} |grep'deb'|grep -v'headers'|grep -v'devel'|awk -F'"''{print $4}')
      #headurl=https://github.com/ylx2016/kernel/releases/download/$github_tag/linux-headers-${github_ver}_${github_ver}-1_amd64.deb
      #imgurl=https://github.com/ylx2016/kernel/releases/download/$github_tag/linux-image-${github_ver}_${github_ver}-1_amd64.deb

      headurl=$(check_cn $headurl)
      imgurl=$(check_cn $imgurl)

      下载文件 $headurl linux-headers-d10.deb
      下载文件 $imgurl linux-image-d10.deb
      dpkg -i linux-镜像-d10.deb
      dpkg -i linux-headers-d10.deb
    elif [[ ${bit} == “aarch64” ]]; 然后
      echo -e "如果下载地址错误，可能当前正在更新，超过半天还是错误请反馈，大陆手机解决污染问题"
      github_tag=$(curl -s'https://api.github.com/repos/ylx2016/kernel/releases'|grep'Debian_Kernel'|grep'_arm64_'|grep'_bbr_'|head -n 1|awk -F'"''{打印 $4}'|awk -F'[/]''{打印 $8}')
      github_ver=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep ${github_tag} | grep 'deb' | grep 'headers' | awk -F '"' '{打印 $4}' | awk -F '[/]' '{打印 $9}' | awk -F '[-]' '{打印 $3}' | awk -F '[_]' '{打印 $1}')
      echo -e "获取的版本号为:${Green_font_prefix}${github_ver}${Font_color_suffix}"
      内核版本=$github_ver
      删除内核头
      headurl = $（curl -s'https://api.github.com/repos/ylx2016/kernel/releases'|grep ${github_tag} |grep'deb'|grep'headers'|awk -F'“''{print $4}'）
      imgurl=$(curl -s'https://api.github.com/repos/ylx2016/kernel/releases'|grep ${github_tag} |grep'deb'|grep -v'headers'|grep -v'devel'|awk -F'"''{print $4}')
      #headurl=https://github.com/ylx2016/kernel/releases/download/$github_tag/linux-headers-${github_ver}_${github_ver}-1_amd64.deb
      #imgurl=https://github.com/ylx2016/kernel/releases/download/$github_tag/linux-image-${github_ver}_${github_ver}-1_amd64.deb

      check_empty $imgurl
      headurl=$(check_cn $headurl)
      imgurl=$(check_cn $imgurl)

      下载文件 $headurl linux-headers-d10.deb
      下载文件 $imgurl linux-image-d10.deb
      dpkg -i linux-镜像-d10.deb
      dpkg -i linux-headers-d10.deb
    别的
      echo -e "${Error} 不支持x86_64及arm64/aarch64以外的系统!" && 出口 1
    菲
  菲

  cd .. && rm -rf bbr

  BBR_grub
  echo -e "${Tip} 内核安装完毕，请参考上面的信息检查安装是否成功，默认从排第一个的高版本内核启动"
  检查内核
}

#安装BBRplus内核 4.14.129
安装bbrplus（）{
  kernel_version="4.14.160-bbrplus"
  位=$(uname -m)
  rm -rf bbrplus
  mkdir bbrplus && cd bbrplus || 退出
  如果 [[ “${OS_type}” == “CentOS” ]]; 然后
    如果 [[ ${version} == "7" ]]; 然后
      如果 [[ ${bit} == "x86_64" ]]; 然后
        内核版本="4.14.129_bbrplus"
        删除内核头
        headurl=https://github.com/cx9208/Linux-NetSpeed/raw/master/bbrplus/centos/7/kernel-headers-4.14.129-bbrplus.rpm
        imgurl=https://github.com/cx9208/Linux-NetSpeed/raw/master/bbrplus/centos/7/kernel-4.14.129-bbrplus.rpm

        headurl=$(check_cn $headurl)
        imgurl=$(check_cn $imgurl)

        download_file $headurl kernel-headers-c7.rpm
        下载文件$imgurl kernel-c7.rpm
        yum 安装 -y 内核-c7.rpm
        yum 安装 -y 内核头文件-c7.rpm
      别的
        echo -e "${Error} 不支持x86_64以外的系统！" && 出口 1
      菲
    菲

  elif [[ “${OS_type}” == “Debian” ]]; 然后
    如果 [[ ${bit} == "x86_64" ]]; 然后
      kernel_version="4.14.129-bbrplus"
      删除内核头
      headurl=https://github.com/cx9208/Linux-NetSpeed/raw/master/bbrplus/debian-ubuntu/x64/linux-headers-4.14.129-bbrplus.deb
      imgurl=https://github.com/cx9208/Linux-NetSpeed/raw/master/bbrplus/debian-ubuntu/x64/linux-image-4.14.129-bbrplus.deb

      headurl=$(check_cn $headurl)
      imgurl=$(check_cn $imgurl)

      wget -O linux-headers.deb $headurl
      wget -O linux-image.deb $imgurl

      dpkg -i linux-镜像.deb
      dpkg -i linux-headers.deb
    别的
      echo -e "${Error} 不支持x86_64以外的系统！" && 出口 1
    菲
  菲

  cd .. && rm -rf bbrplus
  BBR_grub
  echo -e "${Tip} 内核安装完毕，请参考上面的信息检查安装是否成功，默认从排第一个的高版本内核启动"
  检查内核
}

#安装Lotserver内核
安装lot（）{
  位=$(uname -m)
  如果 [[ ${bit} != "x86_64" ]]; 然后
    echo -e "${Error} 不支持x86_64以外的系统！" && 出口 1
  菲
  如果 [[ ${bit} == "x86_64" ]]; 然后
    位='x64'
  菲
  如果 [[ ${bit} == "i386" ]]; 那么
    位='x32'
  菲
  如果 [[ “${OS_type}” == “CentOS” ]]; 然后
    rpm --导入 http://${github}/lotserver/${release}/RPM-GPG-KEY-elrepo.org
    yum 删除 -y 内核固件
    yum 安装 -y http://${github}/lotserver/${release}/${version}/${bit}/kernel-firmware-${kernel_version}.rpm
    yum 安装 -y http://${github}/lotserver/${release}/${version}/${bit}/kernel-${kernel_version}.rpm
    yum 删除 -y 内核头文件
    yum 安装 -y http://${github}/lotserver/${release}/${version}/${bit}/kernel-headers-${kernel_version}.rpm
    yum 安装 -y http://${github}/lotserver/${release}/${version}/${bit}/kernel-devel-${kernel_version}.rpm
  菲

  如果 [[ “${OS_type}” == “Debian” ]]; 然后
    deb_issue="$(cat /etc/issue)"
    deb_relese="$(echo $deb_issue | grep -io 'Ubuntu\|Debian' | sed -r 's/(.*)/\L\1/')"
    os_ver="$(dpkg --print-architecture)"
    [ -n "$os_ver" ] || 退出 1
    if [ "$deb_relese" == 'ubuntu' ];然后
      deb_ver="$(echo $deb_issue | grep -o '[0-9]*\.[0-9]*' | head -n1)"
      如果 [ “$deb_ver” == “14.04” ]; 然后
        kernel_version="3.16.0-77-generic" && item="3.16.0-77-generic" && ver='trusty'
      elif [ “$deb_ver” == “16.04” ]; 然后
        kernel_version="4.8.0-36-generic" && item="4.8.0-36-generic" && ver='xenial'
      elif [ “$deb_ver” == “18.04” ]; 然后
        kernel_version="4.15.0-30-generic" && item="4.15.0-30-generic" && ver='bionic'
      别的
        出口 1
      菲
      url='archive.ubuntu.com'
      urls='security.ubuntu.com'
    elif [ "$deb_relese" == 'debian' ];然后
      deb_ver="$(echo $deb_issue | grep -o '[0-9]*' | head -n1)"
      如果 [ “$deb_ver” == “7” ]; 然后
        kernel_version="3.2.0-4-${os_ver}" && item="3.2.0-4-${os_ver}" && ver='wheezy' && url='archive.debian.org' && urls='archive.debian.org'
      elif [ “$deb_ver” == “8” ]; 然后
        kernel_version="3.16.0-4-${os_ver}" && item="3.16.0-4-${os_ver}" && ver='jessie' && url='archive.debian.org' && urls='archive.debian.org'
      elif [ “$deb_ver” == “9” ]; 然后
        kernel_version="4.9.0-4-${os_ver}" && item="4.9.0-4-${os_ver}" && ver='stretch' && url='archive.debian.org' && urls='archive.debian.org'
      别的
        出口 1
      菲
    菲
    [ -n "$item" ] && [ -n "$urls" ] && [ -n "$url" ] && [ -n "$ver" ] || 退出 1
    if [ "$deb_relese" == 'ubuntu' ];然后
      echo "deb http://${url}/${deb_relese} ${ver} main restricted universe multiverse" >/etc/apt/sources.list
      echo "deb http://${url}/${deb_relese} ${ver}-updates 主要受限宇宙多元宇宙" >>/etc/apt/sources.list
      echo "deb http://${url}/${deb_relese} ${ver}-backports 主要受限宇宙多元宇宙" >>/etc/apt/sources.list
      echo "deb http://${urls}/${deb_relese} ${ver}-security main restricted universe multiverse" >>/etc/apt/sources.list

      apt-get 更新 || apt-get --allow-releaseinfo-change 更新
      apt-get install --no-install-recommends -y linux-image-${item}
    elif [ "$deb_relese" == 'debian' ];然后
      echo "deb http://${url}/${deb_relese} ${ver} main" >/etc/apt/sources.list
      echo "deb-src http://${url}/${deb_relese} ${ver} main" >>/etc/apt/sources.list
      回显“deb http://${urls}/${deb_relese}-security ${ver}/updates main”>>/etc/apt/sources.list
      回显“deb-src http://${urls}/${deb_relese}-security ${ver}/updates main”>>/etc/apt/sources.list

      如果 [ “$deb_ver” == “8” ]; 然后
        dpkg -l | grep -q'linux-base'|| {
          wget --no-check-certificate -qO '/tmp/linux-base_3.5_all.deb' 'http://snapshot.debian.org/archive/debian/20120304T220938Z/pool/main/l/linux-base/linux-base_3.5_all.deb'
          dpkg -i '/tmp/linux-base_3.5_all.deb'
        }
        wget --no-check-certificate -qO '/tmp/linux-image-3.16.0-4-amd64_3.16.43-2+deb8u5_amd64.deb' 'http://snapshot.debian.org/archive/debian/20171008T163152Z/pool/main/l/linux/linux-image-3.16.0-4-amd64_3.16.43-2+deb8u5_amd64.deb'
        dpkg -i '/tmp/linux-image-3.16.0-4-amd64_3.16.43-2+deb8u5_amd64.deb'

        如果 [ $? -ne 0 ]; 那么
          出口 1
        菲
      elif [ “$deb_ver” == “9” ]; 然后
        dpkg -l | grep -q'linux-base'|| {
          wget --no-check-certificate -qO '/tmp/linux-base_4.5_all.deb' 'http://snapshot.debian.org/archive/debian/20160917T042239Z/pool/main/l/linux-base/linux-base_4.5_all.deb'
          dpkg -i '/tmp/linux-base_4.5_all.deb'
        }
        wget --no-check-certificate -qO '/tmp/linux-image-4.9.0-4-amd64_4.9.65-3+deb9u1_amd64.deb' 'http://snapshot.debian.org/archive/debian/20171224T175424Z/pool/main/l/linux/linux-image-4.9.0-4-amd64_4.9.65-3+deb9u1_amd64.deb'
        dpkg -i '/tmp/linux-image-4.9.0-4-amd64_4.9.65-3+deb9u1_amd64.deb'
        ##备选
        #https://sys.if.ci/download/linux-image-4.9.0-4-amd64_4.9.65-3+deb9u1_amd64.deb
        #http://mirror.cs.uchicago.edu/debian-security/pool/updates/main/l/linux/linux-image-4.9.0-4-amd64_4.9.65-3+deb9u1_amd64.deb
        #https://debian.sipwise.com/debian-security/pool/main/l/linux/linux-image-4.9.0-4-amd64_4.9.65-3+deb9u1_amd64.deb
        #http://srv24.dsidata.sk/security.debian.org/pool/updates/main/l/linux/linux-image-4.9.0-4-amd64_4.9.65-3+deb9u1_amd64.deb
        #https://pubmirror.plutex.de/debian-security/pool/updates/main/l/linux/linux-image-4.9.0-4-amd64_4.9.65-3+deb9u1_amd64.deb
        #https://packages.mendix.com/debian/pool/main/l/linux/linux-image-4.9.0-4-amd64_4.9.65-3_amd64.deb
        #http://snapshot.debian.org/archive/debian/20171224T175424Z/pool/main/l/linux/linux-image-4.9.0-4-amd64_4.9.65-3+deb9u1_amd64.deb
        #http://snapshot.debian.org/archive/debian/20171231T180144Z/pool/main/l/linux/linux-image-4.9.0-4-amd64_4.9.65-3_amd64.deb
        如果 [ $? -ne 0 ]; 那么
          出口 1
        菲
      别的
        出口 1
      菲
    菲
    apt-get 自动删除 -y
    [ -d '/var/lib/apt/lists' ] && 查找 /var/lib/apt/lists -type f -delete
  菲

  BBR_grub
  echo -e "${Tip} 内核安装完毕，请参考上面的信息检查安装是否成功，默认从排第一个的高版本内核启动"
  检查内核
}

#从 xanmod.org 安装 xanmod 内核
安装xanmod（）{
  echo -e "xanmod这个自编译版本不维护了，后续请用官方编译版本，知悉。"
  #https://api.github.com/repos/ylx2016/kernel/releases?page=1&per_page=100
  #发布?页面=1&每页=100
  kernel_version="5.5.1-xanmod1"
  位=$(uname -m)
  如果 [[ ${bit} != "x86_64" ]]; 然后
    echo -e "${Error} 不支持x86_64以外的系统！" && 出口 1
  菲
  rm -rf xanmod
  mkdir xanmod && cd xanmod || 退出
  如果 [[ “${OS_type}” == “CentOS” ]]; 然后
    如果 [[ ${version} == "7" ]]; 然后
      如果 [[ ${bit} == "x86_64" ]]; 然后
        echo -e "如果下载地址错误，可能当前正在更新，超过半天还是错误请反馈，大陆手机解决污染问题"
        github_tag=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep 'Centos_Kernel' | grep '_lts_latest_' | grep 'xanmod' | head -n 1 | awk -F '"' '{打印 $4}' | awk -F '[/]' '{打印 $8}')
        github_ver=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep ${github_tag} | grep 'rpm' | grep 'headers' | awk -F '"' '{打印 $4}' | awk -F '[/]' '{打印 $9}' | awk -F '[-]' '{打印 $3}')
        echo -e "获取的版本号为:${Green_font_prefix}${github_ver}${Font_color_suffix}"
        内核版本=$github_ver
        删除内核头
        headurl=$(curl -s'https://api.github.com/repos/ylx2016/kernel/releases'|grep ${github_tag} |grep'rpm'|grep'headers'|awk -F'"''{print $4}')
        imgurl=$(curl -s'https://api.github.com/repos/ylx2016/kernel/releases'|grep ${github_tag}|grep'rpm'|grep -v'headers'|grep -v'devel'|awk -F'"''{print $4}')

        headurl=$(check_cn $headurl)
        imgurl=$(check_cn $imgurl)

        download_file $headurl kernel-headers-c7.rpm
        下载文件$imgurl kernel-c7.rpm
        yum 安装 -y 内核-c7.rpm
        yum 安装 -y 内核头文件-c7.rpm
      别的
        echo -e "${Error} 不支持x86_64以外的系统！" && 出口 1
      菲
    elif [[ ${version} == "8" ]]; 然后
      echo -e "如果下载地址错误，可能当前正在更新，超过半天还是错误请反馈，大陆手机解决污染问题"
      github_tag=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep 'Centos_Kernel' | grep '_lts_C8_latest_' | grep 'xanmod' | head -n 1 | awk -F '"' '{打印 $4}' | awk -F '[/]' '{打印 $8}')
      github_ver=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep ${github_tag} | grep 'rpm' | grep 'headers' | awk -F '"' '{打印 $4}' | awk -F '[/]' '{打印 $9}' | awk -F '[-]' '{打印 $3}')
      echo -e "获取的版本号为:${Green_font_prefix}${github_ver}${Font_color_suffix}"
      内核版本=$github_ver
      删除内核头
      headurl=$(curl -s'https://api.github.com/repos/ylx2016/kernel/releases'|grep ${github_tag} |grep'rpm'|grep'headers'|awk -F'"''{print $4}')
      imgurl=$(curl -s'https://api.github.com/repos/ylx2016/kernel/releases'|grep ${github_tag}|grep'rpm'|grep -v'headers'|grep -v'devel'|awk -F'"''{print $4}')

      headurl=$(check_cn $headurl)
      imgurl=$(check_cn $imgurl)

      wget -O 内核头文件-c8.rpm $headurl
      wget -O kernel-c8.rpm $imgurl
      yum 安装 -y 内核-c8.rpm
      yum 安装 -y 内核头文件-c8.rpm
    菲

  elif [[ “${OS_type}” == “Debian” ]]; 然后

    如果 [[ ${bit} == "x86_64" ]]; 然后
      echo -e "如果下载地址错误，可能当前正在更新，超过半天还是错误请反馈，大陆手机解决污染问题"
      github_tag=$(curl -s'https://api.github.com/repos/ylx2016/kernel/releases'|grep'Debian_Kernel'|grep'_lts_latest_'|grep'xanmod'|head -n 1|awk -F'“''{打印 $4}'|awk -F'[/]''{打印 $8}')
      github_ver=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep ${github_tag} | grep 'deb' | grep 'headers' | awk -F '"' '{打印 $4}' | awk -F '[/]' '{打印 $9}' | awk -F '[-]' '{打印 $3}')

      check_empty $github_ver
      echo -e "获取的xanmod lts版本号为:${github_ver}"

      内核版本=$github_ver

      删除内核头
      headurl = $（curl -s'https://api.github.com/repos/ylx2016/kernel/releases'|grep ${github_tag} |grep'deb'|grep'headers'|awk -F'“''{print $4}'）
      imgurl=$(curl -s'https://api.github.com/repos/ylx2016/kernel/releases'|grep ${github_tag} |grep'deb'|grep -v'headers'|grep -v'devel'|awk -F'"''{print $4}')

      check_empty $imgurl
      headurl=$(check_cn $headurl)
      imgurl=$(check_cn $imgurl)

      下载文件 $headurl linux-headers-d10.deb
      下载文件 $imgurl linux-image-d10.deb
      dpkg -i linux-镜像-d10.deb
      dpkg -i linux-headers-d10.deb
    别的
      echo -e "${Error} 不支持x86_64以外的系统！" && 出口 1
    菲
  菲

  #cd .. && rm -rf xanmod
  BBR_grub
  echo -e "${Tip} 内核安装完毕，请参考上面的信息检查安装是否成功，默认从排第一个的高版本内核启动"
  检查内核
}

#安装bbr2内核集成到xanmod内核了
#安装bbrplus 新内核
#2021.3.15 开始由https://github.com/UJX6N/bbrplus-5.19 替换bbrplusnew
#2021.4.12 地址更新为https://github.com/ylx2016/kernel/releases
#2021.9.2 再次改为https://github.com/UJX6N/bbrplus
#2022.9.6 改为 https://github.com/UJX6N/bbrplus-5.19
#2022.11.24改为https://github.com/UJX6N/bbrplus-6.x_stable

安装bbrplusnew() {
  github_ver_plus=$(curl -s https://api.github.com/repos/UJX6N/bbrplus-6.x_stable/releases | grep /bbrplus-6.x_stable/releases/tag/ | head -1 | awk -F "[/]" '{打印 $8}' | awk -F "[\"]" '{打印 $1}')
  github_ver_plus_num=$(curl -s https://api.github.com/repos/UJX6N/bbrplus-6.x_stable/releases | grep /bbrplus-6.x_stable/releases/tag/ | head -1 | awk -F "[/]" '{打印 $8}' | awk -F "[\"]" '{打印 $1}' | awk -F "[-]" '{打印 $1}')
  echo -e "获取的UJX6N的bbrplus-6.x_stable版本号为:${Green_font_prefix}${github_ver_plus}${Font_color_suffix}"
  echo -e "如果下载地址错误，可能当前正在更新，超过半天还是错误请反馈，大陆手机解决污染问题"
  echo -e "${Green_font_prefix}安装失败反馈反馈，内核问题给UJX6N反馈${Font_color_suffix}"
  # 内核版本=$github_ver_plus

  位=$(uname -m)
  #如果 [[ ${bit} != "x86_64" ]]; 然后
  # echo -e "${Error} 不支持 x86_64 以外的系统 !" && 出口 1
  #fi
  rm -rf bbrplusnew
  mkdir bbrplusnew && cd bbrplusnew || 退出
  如果 [[ “${OS_type}” == “CentOS” ]]; 然后
    如果 [[ ${version} == "7" ]]; 然后
      如果 [[ ${bit} == "x86_64" ]]; 然后
        #github_tag=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep 'Centos_Kernel' | grep '_latest_bbrplus_' | head -n 1 | awk -F '"' '{打印 $4}' | awk -F '[/]' '{打印 $8}')
        #github_ver=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep ${github_tag} | grep 'rpm' | grep 'headers' | awk -F '"' '{打印 $4}' | awk -F '[/]' '{打印 $9}' | awk -F '[-]' '{打印 $3}' | awk -F '[_]' '{打印 $1}')
        #echo -e "获取的版本号为:${Green_font_prefix}${github_ver}${Font_color_suffix}"
        kernel_version=${github_ver_plus_num}-bbrplus
        删除内核头
        headurl = $（curl -s'https://api.github.com/repos/UJX6N/bbrplus-6.x_stable/releases'|grep ${github_ver_plus} |grep'rpm'|grep'headers'|grep'el7'|awk -F'“''{print $4}'|grep'http'）
        imgurl=$(curl -s 'https://api.github.com/repos/UJX6N/bbrplus-6.x_stable/releases' | grep ${github_ver_plus} | grep 'rpm' | grep -v 'devel' | grep -v '标题' | grep -v '源' | awk -F '"' '{print $4}' | grep 'http')

        headurl=$(check_cn $headurl)
        imgurl=$(check_cn $imgurl)

        wget -O kernel-c7.rpm $headurl
        wget -O 内核头-c7.rpm $imgurl
        yum 安装 -y 内核-c7.rpm
        yum 安装 -y 内核头文件-c7.rpm
      别的
        echo -e "${Error} 不支持x86_64以外的系统！" && 出口 1
      菲
    菲
    如果 [[ ${version} == "8" ]]; 那么
      如果 [[ ${bit} == "x86_64" ]]; 然后
        #github_tag=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep 'Centos_Kernel' | grep '_latest_bbrplus_' | head -n 1 | awk -F '"' '{打印 $4}' | awk -F '[/]' '{打印 $8}')
        #github_ver=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep ${github_tag} | grep 'rpm' | grep 'headers' | awk -F '"' '{打印 $4}' | awk -F '[/]' '{打印 $9}' | awk -F '[-]' '{打印 $3}' | awk -F '[_]' '{打印 $1}')
        #echo -e "获取的版本号为:${Green_font_prefix}${github_ver}${Font_color_suffix}"
        kernel_version=${github_ver_plus_num}-bbrplus
        删除内核头
        headurl = $（curl -s'https://api.github.com/repos/UJX6N/bbrplus-6.x_stable/releases'|grep ${github_ver_plus} |grep'rpm'|grep'headers'|grep'el8.x86_64'|grep'https'|awk -F'“''{print $4}'|grep'http'）
        imgurl = $（curl -s'https://api.github.com/repos/UJX6N/bbrplus-6.x_stable/releases'|grep ${github_ver_plus} |grep'rpm'|grep -v'devel'|grep -v'headers'|grep -v'Source'|grep'el8.x86_64'|grep'https'|awk -F'“''{print $4}'|grep'http'）

        headurl=$(check_cn $headurl)
        imgurl=$(check_cn $imgurl)

        wget -O kernel-c8.rpm $headurl
        wget -O 内核头文件-c8.rpm $imgurl
        yum 安装 -y 内核-c8.rpm
        yum 安装 -y 内核头文件-c8.rpm
      别的
        echo -e "${Error} 不支持x86_64以外的系统！" && 出口 1
      菲
    菲
  elif [[ “${OS_type}” == “Debian” ]]; 然后
    如果 [[ ${bit} == "x86_64" ]]; 然后
      #github_tag=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep 'Ubuntu_Kernel' | grep '_latest_bbrplus_' | head -n 1 | awk -F '"' '{打印 $4}' | awk -F '[/]' '{打印 $8}')
      #github_ver=$(curl -s 'http s://api.github.com/repos/ylx2016/kernel/releases' | grep ${github_tag} | grep 'deb' | grep 'headers' | awk -F '"' '{打印 $4}' | awk -F '[/]' '{打印 $9}' | awk -F '[-]' '{打印 $3}' | awk -F '[_]' '{打印 $1}')
      #echo -e "获取的版本号为:${Green_font_prefix}${github_ver}${Font_color_suffix}"
      kernel_version=${github_ver_plus_num}-bbrplus
      删除内核头
      headurl = $（curl -s'https://api.github.com/repos/UJX6N/bbrplus-6.x_stable/releases'|grep ${github_ver_plus} |grep'https'|grep'amd64.deb'|grep'headers'|awk -F'“''{print $4}'|grep'http'）
      imgurl = $（curl -s'https://api.github.com/repos/UJX6N/bbrplus-6.x_stable/releases'|grep ${github_ver_plus} |grep'https'|grep'amd64.deb'|grep'image'|awk -F'“''{print $4}'|grep'http'）

      headurl=$(check_cn $headurl)
      imgurl=$(check_cn $imgurl)

      下载文件 $headurl linux-headers-d10.deb
      下载文件 $imgurl linux-image-d10.deb
      dpkg -i linux-镜像-d10.deb
      dpkg -i linux-headers-d10.deb
    elif [[ ${bit} == “aarch64” ]]; 然后
      #github_tag=$(curl -s 'https://api.github.com/repos/ylx2016/kernel/releases' | grep 'Ubuntu_Kernel' | grep '_latest_bbrplus_' | head -n 1 | awk -F '"' '{打印 $4}' | awk -F '[/]' '{打印 $8}')
      #github_ver=$(curl -s 'http s://api.github.com/repos/ylx2016/kernel/releases' | grep ${github_tag} | grep 'deb' | grep 'headers' | awk -F '"' '{打印 $4}' | awk -F '[/]' '{打印 $9}' | awk -F '[-]' '{打印 $3}' | awk -F '[_]' '{打印 $1}')
      #echo -e "获取的版本号为:${Green_font_prefix}${github_ver}${Font_color_suffix}"
      kernel_version=${github_ver_plus_num}-bbrplus
      删除内核头
      headurl = $（curl -s'https://api.github.com/repos/UJX6N/bbrplus-6.x_stable/releases'|grep ${github_ver_plus} |grep'https'|grep'arm64.deb'|grep'headers'|awk -F'“''{print $4}'）
      imgurl=$(curl -s'https://api.github.com/repos/UJX6N/bbrplus-6.x_stable/releases'|grep ${github_ver_plus}|grep'https'|grep'arm64.deb'|grep'image'|awk -F'"''{print $4}')

      headurl=$(check_cn $headurl)
      imgurl=$(check_cn $imgurl)

      下载文件 $headurl linux-headers-d10.deb
      下载文件 $imgurl linux-image-d10.deb
      dpkg -i linux-镜像-d10.deb
      dpkg -i linux-headers-d10.deb
    别的
      echo -e "${Error} 不支持x86_64及arm64/aarch64以外的系统!" && 出口 1
    菲
  菲

  cd .. && rm -rf bbrplusnew
  BBR_grub
  echo -e "${Tip} 内核安装完毕，请参考上面的信息检查安装是否成功，默认从排第一个的高版本内核启动"
  检查内核

}

#启用BBR+fq
启动bbrfq（）{
  remove_bbr_lotserver
  回显“net.core.default_qdisc=fq”>>/etc/sysctl.d/99-sysctl.conf
  回显“net.ipv4.tcp_congestion_control=bbr”>>/etc/sysctl.d/99-sysctl.conf
  sysctl --系统
  echo -e "${Info}BBR+FQ修改成功，重启生效！"
}

#启用BBR+fq_pie
启动bbrfqpie（）{
  remove_bbr_lotserver
  echo "net.core.default_qdisc=fq_pie" >>/etc/sysctl.d/99-sysctl.conf
  回显“net.ipv4.tcp_congestion_control=bbr”>>/etc/sysctl.d/99-sysctl.conf
  sysctl --系统
  echo -e "${Info}BBR+FQ_PIE修改成功，重启生效！"
}

#启用BBR+cake
开始蛋糕() {
  remove_bbr_lotserver
  回显“net.core.default_qdisc=cake”>>/etc/sysctl.d/99-sysctl.conf
  回显“net.ipv4.tcp_congestion_control=bbr”>>/etc/sysctl.d/99-sysctl.conf
  sysctl --系统
  echo -e "${Info}BBR+cake修改成功，重启生效！"
}

#启用BBRplus
启动bbrplus（）{
  remove_bbr_lotserver
  回显“net.core.default_qdisc=fq”>>/etc/sysctl.d/99-sysctl.conf
  回显“net.ipv4.tcp_congestion_control=bbrplus”>>/etc/sysctl.d/99-sysctl.conf
  sysctl --系统
  echo -e "${Info}BBRplus修改成功，重启生效！"
}

#启用Lotserver
启动lotserver（）{
  remove_bbr_lotserver
  如果 [[ “${OS_type}” == “CentOS” ]]; 然后
    yum 安装 ethtool -y
  别的
    apt-get 更新 || apt-get --allow-releaseinfo-change 更新
    apt-get 安装 ethtool -y
  菲
  #bash <(wget -qO- https://git.io/lotServerInstall.sh) 安装
  #echo | bash <(wget --no-check-certificate -qO- https://raw.githubusercontent.com/1265578519/lotServer/main/lotServerInstall.sh) 安装
  echo | bash <(wget --no-check-certificate -qO- https://raw.githubusercontent.com/fei5seven/lotServer/master/lotServerInstall.sh) 安装
  sed -i '/advinacc/d' /appex/etc/config
  sed -i'/maxmode/d'/appex/etc/config
  echo -e "advinacc=\"1\"
maxmode = \“1 \”>> /appex/etc/config
  /appex/bin/lotServer.sh 重新启动
  开始菜单
}

#启用BBR2+FQ
启动bbr2fq（）{
  remove_bbr_lotserver
  回显“net.core.default_qdisc=fq”>>/etc/sysctl.d/99-sysctl.conf
  回显“net.ipv4.tcp_congestion_control=bbr2”>>/etc/sysctl.d/99-sysctl.conf
  sysctl --系统
  echo -e "${Info}BBR2修改成功，重启生效！"
}

#启用BBR2+FQ_PIE
启动bbr2fqpie() {
  remove_bbr_lotserver
  echo "net.core.default_qdisc=fq_pie" >>/etc/sysctl.d/99-sysctl.conf
  回显“net.ipv4.tcp_congestion_control=bbr2”>>/etc/sysctl.d/99-sysctl.conf
  sysctl --系统
  echo -e "${Info}BBR2修改成功，重启生效！"
}

#启用BBR2+CAKE
启动bbr2cake（）{
  remove_bbr_lotserver
  回显“net.core.default_qdisc=cake”>>/etc/sysctl.d/99-sysctl.conf
  回显“net.ipv4.tcp_congestion_control=bbr2”>>/etc/sysctl.d/99-sysctl.conf
  sysctl --系统
  echo -e "${Info}BBR2修改成功，重启生效！"
}

#开启ecn
启动tecn（）{
  sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf

  回显“net.ipv4.tcp_ecn=1”>>/etc/sysctl.d/99-sysctl.conf
  sysctl --系统
  echo -e "${Info}开启ecn结束！"
}

#关闭ecn
关闭ecn（）{
  sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf

  回显“net.ipv4.tcp_ecn=0”>>/etc/sysctl.d/99-sysctl.conf
  sysctl --系统
  echo -e "${Info}关闭ecn结束！"
}

#卸载bbr+锐速
remove_bbr_lotserver（）{
  sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.core.default_qdisc/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf
  sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
  sysctl --系统

  rm -rf bbrmod

  如果 [[ -e /appex/bin/lotServer.sh ]]; 那么
    回声| bash <(wget -qO- https://raw.githubusercontent.com/fei5seven/lotServer/master/lotServerInstall.sh) 卸载
  菲
  清除
  # echo -e "${Info}:清除bbr/lotserver加速完成。"
  # 睡眠 1 秒
}

#卸载全部加速
删除所有（）{
  rm -rf /etc/sysctl.d/*.conf
  #rm -rf /etc/sysctl.conf
  #触摸/etc/sysctl.conf
  如果 [ !-f "/etc/sysctl.conf" ]; 那么
    触摸/etc/sysctl.conf
  别的
    cat /dev/null >/etc/sysctl.conf
  菲
  sysctl --系统
  sed -i '/DefaultTimeoutStartSec/d' /etc/systemd/system.conf
  sed -i '/DefaultTimeoutStopSec/d' /etc/systemd/system.conf
  sed -i '/DefaultRestartSec/d' /etc/systemd/system.conf
  sed -i '/DefaultLimitCORE/d' /etc/systemd/system.conf
  sed -i '/DefaultLimitNOFILE/d' /etc/systemd/system.conf
  sed -i '/DefaultLimitNPROC/d' /etc/systemd/system.conf

  sed -i '/soft nofile/d' /etc/security/limits.conf
  sed -i'/hard nofile/d'/etc/security/limits.conf
  sed -i '/soft nproc/d' /etc/security/limits.conf
  sed -i'/hard nproc/d'/etc/security/limits.conf

  sed -i '/ulimit -SHn/d' /etc/profile
  sed -i '/ulimit -SHn/d' /etc/profile
  sed -i '/required pam_limits.so/d' /etc/pam.d/common-session

  systemctl 守护进程重新加载

  rm -rf bbrmod
  sed -i '/net.ipv4.tcp_retries2/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_slow_start_after_idle/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_fastopen/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf
  sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
  sed -i'/fs.file-max/d'/etc/sysctl.conf
  sed -i '/net.core.rmem_max/d' /etc/sysctl.conf
  sed -i '/net.core.wmem_max/d' /etc/sysctl.conf
  sed -i '/net.core.rmem_default/d' /etc/sysctl.conf
  sed -i '/net.core.wmem_default/d' /etc/sysctl.conf
  sed -i'/net.core.netdev_max_backlog/d'/etc/sysctl.conf
  sed -i'/net.core.somaxconn/d'/etc/sysctl.conf
  sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_tw_recycle/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_keepalive_time/d' /etc/sysctl.conf
  sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_rmem/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_wmem/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_mtu_probing/d' /etc/sysctl.conf
  sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
  sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
  sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
  sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
  sed -i'/net.core.somaxconn/d'/etc/sysctl.conf
  sed -i'/net.core.netdev_max_backlog/d'/etc/sysctl.conf
  sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
  如果 [[ -e /appex/bin/lotServer.sh ]]; 那么
    bash <(wget -qO- https://raw.githubusercontent.com/fei5seven/lotServer/master/lotServerInstall.sh) 卸载
  菲
  清除
  echo -e "${Info}:清除加速完成。"
  睡眠 1 秒
}

#优化系统配置
优化系统（）{
  如果 [ !-f "/etc/sysctl.conf" ]; 那么
    触摸/etc/sysctl.conf
  菲
  sed -i '/net.ipv4.tcp_retries2/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_slow_start_after_idle/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_fastopen/d' /etc/sysctl.conf
  sed -i'/fs.file-max/d'/etc/sysctl.conf
  sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
  sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
  sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
  sed -i'/net.core.somaxconn/d'/etc/sysctl.conf
  sed -i'/net.core.netdev_max_backlog/d'/etc/sysctl.conf
  sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
  sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf

  回显“net.ipv4.tcp_retries2 = 8
net.ipv4.tcp_slow_start_after_idle = 0
fs.文件最大值 = 1000000
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768
# 转发 ipv4
#net.ipv4.ip_forward = 1” >>/etc/sysctl.conf
  系统控制-p
  echo "* soft nofile 1000000
* 硬无文件 1000000” >/etc/security/limits.conf
  回显“ulimit -SHn 1000000”>>/etc/profile
  read -p "需要重启VPS后，才能生效系统优化配置，是否现在重启？ [Y/n] :" yn
  [ -z “${yn}” ] && yn="y"
  如果 [[ $yn == [Yy] ]]; 那么
    echo -e "${Info} VPS 重启中..."
    重启
  菲
}

优化系统_johnrosen1() {
  如果 [ !-f "/etc/sysctl.d/99-sysctl.conf" ]; 那么
    触摸/etc/sysctl.d/99-sysctl.conf
  菲
  sed -i '/net.ipv4.tcp_fack/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_early_retrans/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.neigh.default.unres_qlen/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.netfilter.nf_conntrack_buckets/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/kernel.pid_max/d' /etc/sysctl.d/99-sysctl.conf
  sed -i'/vm.nr_hugepages/d'/etc/sysctl.d/99-sysctl.conf
  sed -i '/net.core.optmem_max/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.conf.all.route_localnet/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.conf.all.forwarding/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.conf.default.forwarding/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.conf.all.forwarding/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.conf.default.forwarding/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.conf.lo.forwarding/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.conf.all.accept_ra/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.conf.default.accept_ra/d' /etc/sysctl.d/99-sysctl.conf
  sed -i'/net.core.netdev_max_backlog/d'/etc/sysctl.d/99-sysctl.conf
  sed -i'/net.core.netdev_budget/d'/etc/sysctl.d/99-sysctl.conf
  sed -i '/net.core.netdev_budget_usecs/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/fs.file-max /d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.core.rmem_max/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.core.wmem_max/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.core.rmem_default/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.core.wmem_default/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.core.somaxconn/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.icmp_echo_ignore_all/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.icmp_echo_ignore_broadcasts/d' /etc/sysctl.d/99-sysctl.conf
  sed -i'/net.ipv4.icmp_ignore_bogus_error_responses/d'/etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.conf.all.accept_redirects/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.conf.default.accept_redirects/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.conf.all.secure_redirects/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.conf.default.secure_redirects/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.conf.all.send_redirects/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.conf.default.send_redirects/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.conf.default.rp_filter/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.conf.all.rp_filter/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_keepalive_time/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_keepalive_intvl/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_keepalive_probes/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_rfc1337/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_fastopen/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_rmem/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_wmem/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.udp_rmem_min/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.udp_wmem_min/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_mtu_probing/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.conf.all.arp_ignore /d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.conf.default.arp_ignore/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.conf.all.arp_announce/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.conf.default.arp_announce/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_autocorking/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_slow_start_after_idle/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.core.default_qdisc/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_notsent_lowat/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_no_metrics_save/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_ecn_fallback/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_frto/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.conf.all.accept_redirects/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.conf.default.accept_redirects/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/vm.swappiness/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.ip_unprivileged_port_start/d' /etc/sysctl.d/99-sysctl.conf
  sed -i'/vm.overcommit_memory/d'/etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.neigh.default.gc_thresh3/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.neigh.default.gc_thresh2/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.neigh.default.gc_thresh1/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.neigh.default.gc_thresh3/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.neigh.default.gc_thresh2/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.neigh.default.gc_thresh1/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.netfilter.nf_conntrack_max/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.nf_conntrack_max/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.netfilter.nf_conntrack_tcp_timeout_fin_wait/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.netfilter.nf_conntrack_tcp_timeout_time_wait/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.netfilter.nf_conntrack_tcp_timeout_close_wait/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.netfilter.nf_conntrack_tcp_timeout_established/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/fs.inotify.max_user_watches/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_low_latency/d' /etc/sysctl.d/99-sysctl.conf

  cat >'/etc/sysctl.d/99-sysctl.conf'<<EOF
net.ipv4.tcp_fack = 1
net.ipv4.tcp_early_retrans = 3
net.ipv4.neigh.default.unres_qlen=10000  
net.ipv4.conf.all.route_localnet=1
net.ipv4.ip_forward = 1
net.ipv4.conf.all.转发 = 1
net.ipv4.conf.默认.转发 = 1
#net.ipv6.conf.all.forwarding = 1 #awsipv6问题
net.ipv6.conf.默认.转发 = 1
net.ipv6.conf.lo.转发 = 1
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.默认.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
net.ipv6.conf.all.accept_ra = 2
net.ipv6.conf.default.accept_ra = 2
net.core.netdev_max_backlog = 100000
net.core.netdev_budget = 50000
net.core.netdev_budget_usecs = 5000
#fs.file-max = 51200
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.rmem_default = 67108864
net.core.wmem_default = 67108864
net.core.optmem_max = 65536
net.core.somaxconn = 1000000
net.ipv4.icmp_echo_ignore_all = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.all.rp_filter = 0
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_keepalive_probes = 2
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_rfc1337 = 0
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_tw_reuse = 0
net.ipv4.tcp_fin_timeout = 15
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.udp_rmem_min = 8192
net.ipv4.udp_wmem_min = 8192
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_autocorking = 0
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_max_syn_backlog = 819200
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_no_metrics_save = 0
net.ipv4.tcp_ecn = 1
net.ipv4.tcp_ecn_fallback = 1
net.ipv4.tcp_frto = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv4.neigh.默认.gc_thresh3=8192
net.ipv4.neigh.默认.gc_thresh2=4096
net.ipv4.neigh.默认.gc_thresh1=2048
net.ipv6.neigh.默认.gc_thresh3=8192
net.ipv6.neigh.默认.gc_thresh2=4096
net.ipv6.neigh.default.gc_thresh1=2048
net.ipv4.tcp_orphan_retries = 1
net.ipv4.tcp_retries2 = 5
vm.swappiness = 1
vm.overcommit_memory = 1
内核.pid_max=64000
net.netfilter.nf_conntrack_max = 262144
net.nf_conntrack_max = 262144
## 启用 bbr
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_low_latency = 1
末梢血
  系统控制-p
  sysctl --系统
  echo 总是> / sys / kernel / mm / transparent_hugepage / enabled

  cat >'/etc/systemd/system.conf' <<EOF
[经理]
#默认超时开始时间=90秒
默认超时停止秒=30秒
#默认重启时间=100ms
DefaultLimitCORE=无穷大
DefaultLimitNOFILE=无穷大
DefaultLimitNPROC=无穷大
DefaultTasksMax=infinity
末梢血

  cat >'/etc/security/limits.conf'<<EOF
root 软 nofile 1000000
root 硬 nofile 1000000
root 软 nproc 无限
root 硬 nproc 无限
root 软核无限
root 硬核无限
root 硬 memlock 无限
root 软 memlock 无限
* 软无文件 1000000
* 硬无文件 1000000
* 软 nproc 无限
* 硬 nproc 无限制
* 软核无限制
* 硬核无限
* 硬内存锁不受限制
* 软 memlock 无限制
末梢血

  sed -i '/ulimit -SHn/d' /etc/profile
  sed -i'/ulimit -SHu/d'/etc/profile
  回显“ulimit -SHn 1000000”>>/etc/profile

  如果 grep -q "pam_limits.so" /etc/pam.d/common-session; 那么
    ：
  别的
    sed -i '/required pam_limits.so/d' /etc/pam.d/common-session
    echo “会话需要 pam_limits.so” >>/etc/pam.d/common-session
  菲
  systemctl 守护进程重新加载
  echo -e "${Info}优化方案2应用结束，可能需要重启！"
}

优化_ddcc() {
  sed -i '/net.ipv4.conf.all.rp_filter/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.d/99-sysctl.conf

  回显“net.ipv4.conf.all.rp_filter = 1”>>/etc/sysctl.d/99-sysctl.conf
  回显“net.ipv4.tcp_syncookies = 1”>>/etc/sysctl.d/99-sysctl.conf
  回显“net.ipv4.tcp_max_syn_backlog = 1024”>>/etc/sysctl.d/99-sysctl.conf
  系统控制-p
  sysctl --系统
}

#更新脚本
更新Shell() {
  本地 shell_file
  shell_file="$(readlink -f "$0")"
  本地 shell_url="https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcpx.sh"

  # 下载最新版本的脚本
  wget -O "/tmp/tcpx.sh" "$shell_url" &>/dev/null

  # 比较本地和远程脚本的 md5 值
  本地 md5_本地
  本地 md5_远程
  md5_local="$(md5sum"$shell_file" | awk'{打印$1}')"
  md5_remote="$(md5sum /tmp/tcpx.sh | awk'{打印$1}')"

  如果 [ “$md5_local” != “$md5_remote” ]; 然后
    # 替换本地脚本文件
    cp “/tmp/tcpx.sh” “$shell_file”
    chmod + x "$shell_file" 复制代码

    echo "剧本已更新，请重新运行。"
    出口 0
  别的
    echo "剧本是最新版本，已更新。"
  菲
}

# 转到卸载内核版本
gototcp() {
  清除
  #wget -O tcp.sh "https://github.com/ylx2016/Linux-NetSpeed/raw/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
  bash <(wget -qO- https://github.com/ylx2016/Linux-NetSpeed/raw/master/tcp.sh)
}

#切换到秋水逸冰BBR安装脚本
gototeddysun_bbr() {
  清除
  #wget https://github.com/teddysun/across/raw/master/bbr.sh && chmod +x bbr.sh && ./bbr.sh
  bash <(wget -qO- https://github.com/teddysun/across/raw/master/bbr.sh)
}

# 切换到一键DD安装系统脚本新手勿入
gotodd（）{
  清除
  echo DD使用git.beta.gs的脚本，知悉
  睡眠 1.5
  #wget -O NewReinstall.sh https://github.com/fcurrk/reinstall/raw/master/NewReinstall.sh && chmod a+x NewReinstall.sh && bash NewReinstall.sh
  bash <(wget -qO- https://github.com/fcurrk/reinstall/raw/master/NewReinstall.sh)
  #wget -qO ~/Network-Reinstall-System-Modify.sh 'https://github.com/ylx2016/reinstall/raw/master/Network-Reinstall-System-Modify.sh' && chmod a+x ~/Network-Reinstall-System-Modify.sh && bash ~/Network-Reinstall-System-Modify.sh -UI_Options
}

#禁用IPv6
关闭ipv6（）{
  清除
  sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
  sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
  sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.conf

  回显“net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1”>>/etc/sysctl.d/99-sysctl.conf
  sysctl --系统
  echo -e "${Info}取消IPv6结束，可能需要重启！"
}

#开启IPv6
openipv6() {
  清除
  sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.d/99-sysctl.conf
  sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
  sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
  sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.conf
  sed -i '/net.ipv6.conf.all.accept_ra/d' /etc/sysctl.conf
  sed -i '/net.ipv6.conf.default.accept_ra/d' /etc/sysctl.conf

  回显“net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.默认.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
net.ipv6.conf.all.accept_ra = 2
net.ipv6.conf.default.accept_ra = 2”>>/etc/sysctl.d/99-sysctl.conf
  sysctl --系统
  echo -e "${Info}开启IPv6结束，可能需要重启！"
}

#开始菜单
开始菜单() {
  清除
  echo && echo -e " 加速管理 FEEMO--方生 ${Red_font_prefix}[v${sh_ver}] 不卸载内核${Font_color_suffix} 
 ${Green_font_prefix}0.${Font_color_suffix}升级脚本
 ${Green_font_prefix}9.${Font_color_suffix} 切换到卸载版本 ${Green_font_prefix}10.${Font_color_suffix} 切换到一键DD系统脚本
 ${Green_font_prefix}1.${Font_color_suffix}安装BBR原版内核 ${Green_font_prefix}7.${Font_color_suffix}安装Zen官方版内核
 ${Green_font_prefix}2.${Font_color_suffix}安装BBRplus新版内核 ${Green_font_prefix}5.${Font_color_suffix}安装BBRplus新版内核
 ${Green_font_prefix}3.${Font_color_suffix}安装Lotserver(锐速)内核 ${Green_font_prefix}36.${Font_color_suffix}安装XANMOD官方内核(EDGE)
 ${Green_font_prefix}30.${Font_color_suffix} 安装官方稳定内核 ${Green_font_prefix}31.${Font_color_suffix} 安装官方最新内核 backports/elrepo
 ${Green_font_prefix}32.${Font_color_suffix}安装XANMOD官方内核(main) ${Green_font_prefix}33.${Font_color_suffix}安装XANMOD官方内核(LTS)
 ${Green_font_prefix}11.${Font_color_suffix} 使用BBR+FQ加速 ${Green_font_prefix}12.${Font_color_suffix} 使用BBR+FQ_PIE加速
 ${Green_font_prefix}13.${Font_color_suffix} 使用BBR+CAKE加速
 ${Green_font_prefix}14.${Font_color_suffix} 使用BBR2+FQ加速 ${Green_font_prefix}15.${Font_color_suffix} 使用BBR2+FQ_PIE加速
 ${Green_font_prefix}16.${Font_color_suffix} 使用BBR2+CAKE加速
 ${Green_font_prefix}17.${Font_color_suffix} 开启ECN ${Green_font_prefix}18.${Font_color_suffix} 关闭ECN
 ${Green_font_prefix}19.${Font_color_suffix} 使用BBRplus+FQ版加速 ${Green_font_prefix}20.${Font_color_suffix} 使用Lotserver(锐速)加速
 ${Green_font_prefix}21.${Font_color_suffix}系统配置优化 ${Green_font_prefix}22.${Font_color_suffix}应用优化方案2
 ${Green_font_prefix}23.${Font_color_suffix} 禁用IPv6 ${Green_font_prefix}24.${Font_color_suffix} 开启IPv6
 ${Green_font_prefix}51.${Font_color_suffix}查看排序内核 ${Green_font_prefix}52.${Font_color_suffix} 删除保留指定内核
 ${Green_font_prefix}25.${Font_color_suffix}卸载全部加速${Green_font_prefix}99.${Font_color_suffix}退出脚本
————————————————————————————————————————————————————— ————————————”&&
    检查状态
  获取系统信息
  echo -e " 系统信息: ${Font_color_suffix}$opsy ${Green_font_prefix}$virtual${Font_color_suffix} $arch ${Green_font_prefix}$kern${Font_color_suffix} "
  如果 [[ ${kernel_status} == "noinstall" ]]; 那么
    echo -e " 当前状态: ${Green_font_prefix}未安装${Font_color_suffix} 加速内核${Red_font_prefix}请先安装内核${Font_color_suffix}"
  别的
    echo -e " 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} ${Red_font_prefix}${kernel_status}${Font_color_suffix}加速内核, ${Green_font_prefix}${run_status}${Font_color_suffix}"

  菲
  echo -e " 当前优先塞控制算法为: ${Green_font_prefix}${net_congestion_control}${Font_color_suffix} 当前队列算法为: ${Green_font_prefix}${net_qdisc}${Font_color_suffix} "

  read -p " 请输入数字 :" num
  案例“$num”
  0）
    更新外壳
    ；；
  1）
    检查系统信息
    ；；
  2）
    检查系统是否正确运行
    ；；
  3）
    检查系统日志
    ；；
  5）
    check_sys_bbrplusnew
    ；；
  7）
    检查系统是否正常运行
    ；；
  30）
    检查系统官方
    ；；
  31）
    检查系统是否正常运行
    ；；
  32）
    check_sys_official_xanmod_main
    ；；
  33）
    check_sys_official_xanmod_lts
    ；；
  36）
    check_sys_official_xanmod_edge
    ；；
  9）
    戈托特克
    ；；
  10）
    戈托德
    ；；
  11）
    启动bbrfq
    ；；
  12）
    启动bbrfqpie
    ；；
  13）
    开始蛋糕
    ；；
  14）
    启动bbr2fq
    ；；
  15）
    启动bbr2fqpie
    ；；
  16）
    开始bbr2cake
    ；；
  17）
    星科
    ；；
  18）
    关闭
    ；；
  19）
    启动bbrplus
    ；；
  20）
    启动lot服务器
    ；；
  21）
    优化系统
    ；；
  22）
    优化系统_johnrosen1
    ；；
  23）
    关闭IPv6
    ；；
  24）
    openipv6
    ；；
  25）
    删除所有
    ；；
  26）
    优化_ddcc
    ；；
  51）
    BBR_grub
    ；；
  52）
    删除内核自定义
    ；；
  99）
    出口 1
    ；；
  *）
    清除
    echo -e "${Error}:请输入正确的数字[0-99]"
    睡眠 5 秒
    开始菜单
    ；；
  埃萨克
}
############ 内核管理组件############

#删除多余内核
detele_kernel（）{
  如果 [[ “${OS_type}” == “CentOS” ]]; 然后
    rpm_total=$(rpm -qa | grep kernel | grep -v "${kernel_version}" | grep -v "noarch" | wc -l)
    如果 [ "${rpm_total}" ] > "1"; 那么
      echo -e "检测到${rpm_total}个其余内核，开始卸载..."
      对于（（整数 = 1；整数 <= ${rpm_total}；整数++））；执行
        rpm_del=$(rpm -qa | grep 内核 | grep -v "${kernel_version}" | grep -v "noarch" | head -${integer})
        echo -e "开始卸载 ${rpm_del} 内核..."
        rpm --nodeps -e ${rpm_del}
        echo -e "卸载 ${rpm_del} 内核卸载完成，继续..."
      完毕
      echo --nodeps -e "卸载卸载完毕，继续..."
    别的
      echo -e "检测到内核数量不正确，请检查!" && 出口 1
    菲
  elif [[ “${OS_type}” == “Debian” ]]; 然后
    deb_total = $（dpkg -l | grep linux-image | awk'{打印$ 2}'| grep -v“${kernel_version}”| wc -l）
    如果 [ “${deb_total}” ] > “1”; 然后
      echo -e "检测到${deb_total}个其余内核，开始卸载..."
      对于（（整数 = 1；整数 <= ${deb_total}；整数++））；执行
        deb_del = $（dpkg -l | grep linux-image | awk'{print $2}'| grep -v“${kernel_version}”| head -${integer}）
        echo -e "开始卸载 ${deb_del} 内核..."
        apt-get purge -y ${deb_del}
        apt-get 自动删除 -y
        echo -e "卸载${deb_del} 卸载卸载完成，继续..."
      完毕
      echo -e "内核卸载完毕，继续..."
    别的
      echo -e "检测到内核数量不正确，请检查!" && 出口 1
    菲
  菲
}

删除内核头() {
  如果 [[ “${OS_type}” == “CentOS” ]]; 然后
    rpm_total = $（rpm -qa | grep 内核头| grep -v“$ {kernel_version}”| grep -v“noarch”| wc -l）
    如果 [ "${rpm_total}" ] > "1"; 那么
      echo -e "检测到${rpm_total}个其余head内核，开始卸载..."
      对于（（整数 = 1；整数 <= ${rpm_total}；整数++））；执行
        rpm_del = $（rpm -qa | grep 内核头 | grep -v“${kernel_version}”| grep -v“noarch”| head -${integer}）
        echo -e "开始卸载 ${rpm_del} headers 内核..."
        rpm --nodeps -e ${rpm_del}
        echo -e "卸载 ${rpm_del} 内核卸载完成，继续..."
      完毕
      echo --nodeps -e "卸载卸载完毕，继续..."
    别的
      echo -e "检测到内核数量不正确，请检查!" && 出口 1
    菲
  elif [[ “${OS_type}” == “Debian” ]]; 然后
    deb_total = $（dpkg -l | grep linux-headers | awk'{打印$ 2}'| grep -v“${kernel_version}”| wc -l）
    如果 [ “${deb_total}” ] > “1”; 然后
      echo -e "检测到${deb_total}个其余head内核，开始卸载..."
      对于（（整数 = 1；整数 <= ${deb_total}；整数++））；执行
        deb_del = $（dpkg -l | grep linux-headers | awk'{打印$ 2}'| grep -v“${kernel_version}”| head -${integer}）
        echo -e "开始卸载 ${deb_del} 标头内核..."
        apt-get purge -y ${deb_del}
        apt-get 自动删除 -y
        echo -e "卸载${deb_del} 卸载卸载完成，继续..."
      完毕
      echo -e "内核卸载完毕，继续..."
    别的
      echo -e "检测到内核数量不正确，请检查!" && 出口 1
    菲
  菲
}

detele_kernel_custom（）{
  BBR_grub
  read -p " 查看上面内核输入需保留保留的内核关键词(如:5.15.0-11) :" kernel_version
  删除内核
  删除内核头
  BBR_grub
}

#更新引导
BBR_grub（）{
  如果 [[ “${OS_type}” == “CentOS” ]]; 然后
    如果 [[ ${version} == "6" ]]; 那么
      如果 [ -f "/boot/grub/grub.conf" ]; 那么
        sed -i 's/^default=.*/default=0/g' /boot/grub/grub.conf
      elif [ -f "/boot/grub/grub.cfg" ]; 然后
        grub-mkconfig -o /boot/grub/grub.cfg
        grub-设置默认 0
      elif [ -f "/boot/efi/EFI/centos/grub.cfg" ]; 然后
        grub-mkconfig -o /boot/efi/EFI/centos/grub.cfg
        grub-设置默认 0
      elif [ -f “/boot/efi/EFI/redhat/grub.cfg” ]; 然后
        grub-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
        grub-设置默认 0
      别的
        echo -e "${Error} grub.conf/grub.cfg 找不到，请检查。"
        出口
      菲
    elif [[ ${version} == "7" ]]; 然后
      如果 [ -f "/boot/grub2/grub.cfg" ]; 那么
        grub2-mkconfig -o /boot/grub2/grub.cfg
        grub2-设置默认 0
      elif [ -f "/boot/efi/EFI/centos/grub.cfg" ]; 然后
        grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
        grub2-设置默认 0
      elif [ -f “/boot/efi/EFI/redhat/grub.cfg” ]; 然后
        grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
        grub2-设置默认 0
      别的
        echo -e "${Error} grub.cfg 找不到，请检查。"
        出口
      菲
    elif [[ ${version} == "8" ]]; 然后
      如果 [ -f "/boot/grub2/grub.cfg" ]; 那么
        grub2-mkconfig -o /boot/grub2/grub.cfg
        grub2-设置默认 0
      elif [ -f "/boot/efi/EFI/centos/grub.cfg" ]; 然后
        grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
        grub2-设置默认 0
      elif [ -f “/boot/efi/EFI/redhat/grub.cfg” ]; 然后
        grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
        grub2-设置默认 0
      别的
        echo -e "${Error} grub.cfg 找不到，请检查。"
        出口
      菲
      grubby --info=ALL | awk -F='$1=="内核" {print i++" : " $2}'
    菲
  elif [[ “${OS_type}” == “Debian” ]]; 然后
    如果存在“update-grub”；则
      更新 grub
    elif [ -f "/usr/sbin/update-grub" ]; 然后
      在/usr/sbin/update-grub中
    别的
      apt 安装 grub2-common -y
      更新 grub
    菲
    #退出 1
  菲
 检查磁盘空间
}

# 概要检查内核
检查内核() {
  如果 [[ -z "$(find /boot -type f -name 'vmlinuz-*' !-name 'vmlinuz-*rescue*')" ]]; 然后
    echo -e "\033[0;31m警告: 未发现内核文件，请勿重启系统，不卸载内核版本选择30安装默认内核救急！\033[0m"
  别的
    echo -e "\033[0;32m找到内核文件，看起来可以重启。\033[0m"
  菲
}

############ 内核管理组件############

############系统检测组件############

#检查系统
check_sys（）{
  如果 [[ -f /etc/redhat-release ]]; 那么
    发布=“centos”
  elif grep -qi "debian" /etc/issue; 然后
    发布=“debian”
  elif grep -qi "ubuntu" /etc/issue; 然后
    发布=“ubuntu”
  elif grep -qi -E "centos|red hat|redhat" /etc/issue || grep -qi -E "centos|red hat|redhat" /proc/version; 然后
    发布=“centos”
  菲

  如果 [[ -f /etc/debian_version ]]; 那么
    OS_type="Debian"
    echo "检测为Debian通用系统，判断有误请反馈"
  elif [[ -f /etc/redhat-release || -f /etc/centos-release || -f /etc/fedora-release ]]; 然后
    OS_type="CentOS"
    echo "检测为CentOS通用系统，判断有错误请反馈"
  别的
    回显“未知”
  菲

  #来自 https://github.com/oooldking

  _存在（）{
    本地命令=“$1”
    如果 eval 类型类型 >/dev/null 2>&1; 那么
      eval 类型“$cmd”>/dev/null 2>&1
    elif 命令 >/dev/null 2>&1; 然后
      命令 -v "$cmd" >/dev/null 2>&1
    别的
      其中“$cmd”> / dev / null 2>＆1
    菲
    本地 rt=$?
    返回 ${rt}
  }

  获取opsy() {
    如果 [ -f /etc/os-release ]; 那么
      awk -F'[=“]''/PRETTY_NAME/{打印$3,$4,$5}'/etc/os-release
    elif [ -f /etc/lsb-release ]; 然后
      awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release
    elif [ -f /etc/system-release ]; 然后
      cat /etc/system-release | awk'{打印$1,$2}'
    菲
  }

  获取系统信息() {
    opsy=$(获取opsy)
    拱=$（uname -m）
    kern=$(uname -r)
    virt_check
  }
  # 来自 LemonBench
  virt_check() {
    如果 [ -f "/usr/bin/systemd-detect-virt" ]; 那么
      Var_VirtType="$(/usr/bin/systemd-detect-virt)"
      #虚拟机检测
      如果 [ “${Var_VirtType}” = “qemu” ]; 然后
        虚拟=“QEMU”
      elif [ "${Var_VirtType}" = "kvm" ];然后
        虚拟=“KVM”
      elif [ "${Var_VirtType}" = "zvm" ];然后
        虚拟=“S390 Z/VM”
      elif [ “${Var_VirtType}” = “vmware” ]; 然后
        虚拟=“VMware”
      elif [ “${Var_VirtType}” = “microsoft” ]; 然后
        虚拟=“Microsoft Hyper-V”
      elif [ “${Var_VirtType}” = “xen” ]; 然后
        虚拟=“Xen 虚拟机管理程序”
      elif [ "${Var_VirtType}" = "bochs" ];然后
        虚拟=“BOCHS”
      elif [ “${Var_VirtType}” = “uml” ]; 然后
        虚拟=“用户模式Linux”
      elif [ “${Var_VirtType}” = “parallels” ]; 然后
        虚拟=“Parallels”
      elif [ “${Var_VirtType}” = “bhyve” ]; 然后
        虚拟=“FreeBSD 虚拟机管理程序”
      # 容器虚拟化
      elif [ “${Var_VirtType}” = “openvz” ]; 然后
        虚拟=“OpenVZ”
      elif [ "${Var_VirtType}" = "lxc" ];然后
        虚拟=“LXC”
      elif [ "${Var_VirtType}" = "lxc-libvirt" ];然后
        虚拟=“LXC（libvirt）”
      elif [ “${Var_VirtType}” = “systemd-nspawn” ]; 然后
        虚拟=“Systemd nspawn”
      elif [ "${Var_VirtType}" = "docker" ];然后
        虚拟=“Docker”
      elif [ "${Var_VirtType}" = "rkt" ];然后
        虚拟=“RKT”
      # 特殊处理
      elif [ -c "/dev/lxss" ];然后#处理WSL虚拟化
        Var_VirtType="wsl"
        虚拟=“适用于 Linux 的 Windows 子系统 (WSL)”
      # 未匹配到任何结果，或者非虚拟机
      elif [ “${Var_VirtType}” = “none” ]; 然后
        Var_VirtType="专用"
        虚拟="无"
        本地 Var_BIOSVendor
        Var_BIOSVendor="$(dmidecode -s bios-vendor)"
        如果 [ “${Var_BIOSVendor}” = “SeaBIOS” ]; 然后
          Var_VirtType="未知"
          virtual="SeaBIOS BIOS 未知"
        别的
          Var_VirtType="专用"
          virtual="专用于 ${Var_BIOSVendor} BIOS"
        菲
      菲
    elif [ !-f "/usr/sbin/virt-what" ]; 然后
      Var_VirtType="未知"
      virtual="[错误：未找到 virt-what！]"
    elif [ -f "/.dockerenv" ];然后#处理Docker虚拟化
      Var_VirtType="docker"
      虚拟=“Docker”
    elif [ -c "/dev/lxss" ];然后#处理WSL虚拟化
      Var_VirtType="wsl"
      虚拟=“适用于 Linux 的 Windows 子系统 (WSL)”
    else#正常判断流程
      Var_VirtType="$(virt-what | xargs)"
      本地 Var_VirtTypeCount
      Var_VirtTypeCount="$(echo $Var_VirtTypeCount | wc -l)"
      if [ "${Var_VirtTypeCount}" -gt "1" ]; then # 处理虚拟化
        虚拟=“回显$ {Var_VirtType}”
        Var_VirtType="$(echo ${Var_VirtType} | head -n1)" #检测使用到的第一种虚拟化继续做判断
      elif [ "${Var_VirtTypeCount}" -eq "1" ] && [ "${Var_VirtType}" != "" ];那么 # 只有一种虚拟化
        虚拟="${Var_VirtType}"
      别的
        本地 Var_BIOSVendor
        Var_BIOSVendor="$(dmidecode -s bios-vendor)"
        如果 [ “${Var_BIOSVendor}” = “SeaBIOS” ]; 然后
          Var_VirtType="未知"
          virtual="SeaBIOS BIOS 未知"
        别的
          Var_VirtType="专用"
          virtual="专用于 ${Var_BIOSVendor} BIOS"
        菲
      菲
    菲
  }

  #检查要求
  如果 [[ “${OS_type}” == “CentOS” ]]; 然后
    #检查是否安装了ca-certificates包，如果未安装则安装
    如果！rpm -q ca-certificates> / dev / null;那么
      echo '正在安装 ca-certificates 包...'
      yum 安装 ca-证书 -y
      更新 CA 信任强制启用
    菲
    echo 'CA证书检查OK'

    #检查并安装curl、wget和dmidecode包
    对于 curl wget dmidecode redhat-lsb-core 中的 pkg；请执行
      如果 ！输入 $pkg >/dev/null 2>&1; 然后
        echo "未安装$pkg，正在安装..."
        yum 安装 $pkg -y
      别的
        echo "$pkg已安装。"
      菲
    完毕

    如果 [ -x "$(command -v lsb_release)" ]; 然后
      echo "lsb_release 已安装"
    别的
      echo "lsb_release 未安装，现在开始安装..."
      yum 安装 epel-release -y
      yum 安装 redhat-lsb-core -y
    菲

  elif [[ “${OS_type}” == “Debian” ]]; 然后
    #检查是否安装了ca-certificates包，如果未安装则安装
    如果 !dpkg-query -W ca-certificates >/dev/null; 那么
      echo '正在安装 ca-certificates 包...'
      apt-get 更新 || apt-get --allow-releaseinfo-change 更新 && apt-get 安装 ca-certificates -y
      更新 CA 证书
    菲
    echo 'CA证书检查OK'

    #检查并安装curl、wget和dmidecode包
    对于 curl wget dmidecode 中的 pkg；请执行
      如果 ！输入 $pkg >/dev/null 2>&1; 然后
        echo "未安装$pkg，正在安装..."
        apt-get 更新 || apt-get --allow-releaseinfo-change 更新 && apt-get 安装 $pkg -y
      别的
        echo "$pkg已安装。"
      菲
    完毕

    如果 [ -x "$(command -v lsb_release)" ]; 然后
      echo "lsb_release 已安装"
    别的
      echo "lsb_release 未安装，现在开始安装..."
      apt-get 安装 lsb-release -y
    菲

  别的
    echo "不支持的发行操作系统版本：${release}"
    出口 1
  菲
}

#检查Linux版本
检查版本() {
  如果 [[ -s /etc/redhat-release ]]; 那么
    版本=$（grep -oE “[0-9.]+” /etc/redhat-release|cut -d.-f 1）
  别的
    版本=$（grep -oE “[0-9.]+” /etc/issue | cut -d . -f 1）
  菲
  位=$(uname -m)
  check_github
}

#检查安装bbr的系统要求
检查系统bbr() {
  检查版本
  如果 [[ “${OS_type}” == “CentOS” ]]; 然后
    如果 [[ ${version} == "7" ]]; 然后
      安装bbr
    别的
      echo -e "${Error} BBR内核不支持当前系统${release} ${version} ${bit} !" && 出口 1
    菲
  elif [[ “${OS_type}” == “Debian” ]]; 然后
    apt-get --fix-broken install -y && apt-get autoremove -y
    安装bbr
  别的
    echo -e "${Error} BBR内核不支持当前系统${release} ${version} ${bit} !" && 出口 1
  菲
}

check_sys_bbrplus() {
  检查版本
  如果 [[ “${OS_type}” == “CentOS” ]]; 然后
    如果 [[ ${version} == "7" ]]; 然后
      安装bbrplus
    别的
      echo -e "${Error} BBRplus内核不支持当前系统${release} ${version} ${bit} !" && 出口 1
    菲
  elif [[ “${OS_type}” == “Debian” ]]; 然后
    apt-get --fix-broken install -y && apt-get autoremove -y
    安装bbrplus
  别的
    echo -e "${Error} BBRplus内核不支持当前系统${release} ${version} ${bit} !" && 出口 1
  菲
}

check_sys_bbrplusnew() {
  检查版本
  如果 [[ “${OS_type}” == “CentOS” ]]; 然后
    #如果 [[ ${version} == "7" ]]; 然后
    如果 [[ ${version} == "7" || ${version} == "8" ]]; 然后
      安装bbrplusnew
    别的
      echo -e "${Error} BBRplusNew内核不支持当前系统${release} ${version} ${bit} !" && 出口 1
    菲
  elif [[ “${OS_type}” == “Debian” ]]; 然后
    apt-get --fix-broken install -y && apt-get autoremove -y
    安装bbrplusnew
  别的
    echo -e "${Error} BBRplusNew内核不支持当前系统${release} ${version} ${bit} !" && 出口 1
  菲
}

check_sys_xanmod() {
  检查版本
  如果 [[ “${OS_type}” == “CentOS” ]]; 然后
    如果 [[ ${version} == "7" || ${version} == "8" ]]; 然后
      安装xanmod
    别的
      echo -e "${Error} xanmod内核不支持当前系统${release} ${version} ${bit} !" && 出口 1
    菲
  elif [[ “${OS_type}” == “Debian” ]]; 然后
    apt-get --fix-broken install -y && apt-get autoremove -y
    安装xanmod
  别的
    echo -e "${Error} xanmod内核不支持当前系统${release} ${version} ${bit} !" && 出口 1
  菲
}

#检查安装Lotsever的系统要求
检查系统日志 () {
  检查版本
  位=$(uname -m)
  如果 [[ ${bit} != "x86_64" ]]; 然后
    echo -e "${Error} 不支持x86_64以外的系统！" && 出口 1
  菲
  如果 [[ “${OS_type}” == “CentOS” ]]; 然后
    如果 [[ ${version} == "6" ]]; 那么
      内核版本="2.6.32-504"
      安装
    elif [[ ${version} == "7" ]]; 然后
      yum -y 安装网络工具
      内核版本="4.11.2-1"
      安装
    别的
      echo -e "${Error} Lotsever不支持当前系统${release} ${version} ${bit} !" && 出口 1
    菲
  elif [[ “${release}” == “debian” ]]; 然后
    如果 [[ ${version} == "7" || ${version} == "8" ]]; 然后
      如果 [[ ${bit} == "x86_64" ]]; 然后
        kernel_version="3.16.0-4"
        安装
      elif [[ ${bit} == "i386" ]]; 然后
        内核版本="3.2.0-4"
        安装
      菲
    elif [[ ${version} == "9" ]]; 然后
      如果 [[ ${bit} == "x86_64" ]]; 然后
        内核版本="4.9.0-4"
        安装
      菲
    别的
      echo -e "${Error} Lotsever不支持当前系统${release} ${version} ${bit} !" && 出口 1
    菲
  elif [[ “${release}” == “ubuntu” ]]; 然后
    如果 [[ ${version} -ge "12" ]]; 然后
      如果 [[ ${bit} == "x86_64" ]]; 然后
        内核版本=“4.4.0-47”
        安装
      elif [[ ${bit} == "i386" ]]; 然后
        内核版本="3.13.0-29"
        安装
      菲
    别的
      echo -e "${Error} Lotsever不支持当前系统${release} ${version} ${bit} !" && 出口 1
    菲
  别的
    echo -e "${Error} Lotsever不支持当前系统${release} ${version} ${bit} !" && 出口 1
  菲
}

#检查官方稳定内核并安装
检查系统官方() {
  检查版本
  位=$(uname -m)
  如果 [[ “${OS_type}” == “CentOS” ]]; 然后
    如果 [[ ${bit} != "x86_64" ]]; 然后
      echo -e "${Error} 不支持x86_64以外的系统！" && 出口 1
    菲
    如果 [[ ${version} == "7" ]]; 然后
      yum 安装内核 kernel-headers -y --skip-broken
    elif [[ ${version} == "8" ]]; 然后
      yum 安装内核 内核核心 内核头 -y --skip-broken
    别的
      echo -e "${Error} 不支持当前系统${release} ${version} ${bit} !" && 出口 1
    菲
  elif [[ “${release}” == “debian” ]]; 然后
    apt 更新
    如果 [[ ${bit} == "x86_64" ]]; 然后
      apt-get 更新 && apt-get 安装 linux-image-amd64 linux-headers-amd64 -y
    elif [[ ${bit} == “aarch64” ]]; 然后
      apt-get 安装 linux-image-arm64 linux-headers-arm64 -y
    菲
  elif [[ “${release}” == “ubuntu” ]]; 然后
    apt 更新
    apt-get 安装 linux-image-generic linux-headers-generic -y
  别的
    echo -e "${Error} 不支持当前系统${release} ${version} ${bit} !" && 出口 1
  菲

  BBR_grub
  echo -e "${Tip} 内核安装完毕，请参考上面的信息检查安装是否成功，默认从排第一个的高版本内核启动"
}

#检查官方最新内核并安装
check_sys_official_bbr() {
  检查版本
  os_name=$(awk -F='/^NAME/{print $2}' /etc/os-release | tr -d'"')
  os_version=$(awk -F='/^VERSION_ID/{print $2}' /etc/os-release | tr -d'"')
  os_arch=$(uname -m)
  位=$(uname -m)
  如果 [[ “${OS_type}” == “CentOS” ]]; 然后
    如果 [[ ${bit} != "x86_64" ]]; 然后
      echo -e "${Error} 不支持x86_64以外的系统！" && 出口 1
    菲
    rpm --导入 https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    如果 [[ ${version} == "7" ]]; 然后
      yum 安装 https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm -y
      yum --enablerepo=elrepo-kernel 安装 kernel-ml kernel-ml-headers -y --skip-broken
    elif [[ ${version} == "8" ]]; 然后
      yum 安装 https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm -y
      yum --enablerepo=elrepo-kernel 安装 kernel-ml kernel-ml-headers -y --skip-broken
    别的
      echo -e "${Error} 不支持当前系统${release} ${version} ${bit} !" && 出口 1
    菲
  elif [[ “${release}” == “debian” ]]; 然后
    案例 ${os_version}
    9）
      回显“deb http://deb.debian.org/debian stretch-backports main”>/etc/apt/sources.list.d/stretch-backports.list
      ；；
    10）
      回显“deb http://deb.debian.org/debian buster-backports main”>/etc/apt/sources.list.d/buster-backports.list
      ；；
    11）
      回显“deb http://deb.debian.org/debian bullseye-backports main”>/etc/apt/sources.list.d/bullseye-backports.list
      ；；
    12）
      回显“deb http://deb.debian.org/debian bookworm-b​​ackports main”>/etc/apt/sources.list.d/bookworm-b​​ackports.list
      ；；
    *）
      echo -e "[Error] 不支持当前系统 ${os_name} ${os_version} ${os_arch} !" && 出口 1
      ；；
    埃萨克

    apt 更新
    如果 [[ ${os_arch} == "x86_64" ]]; 然后
      apt -t“$(lsb_release -cs)-backports”安装\
        Linux 映像-amd64 \
        Linux 标头-amd64 \
        -y
    elif [[ ${os_arch} =~ ^(arm|aarch64)$ ]]; 然后
      apt -t“$(lsb_release -cs)-backports”安装\
        Linux-镜像-arm64 \
        Linux 标头-arm64 \
        -y
    别的
      echo -e "[Error] 不支持当前系统架构 ${os_arch} !" && 出口 1
    菲
  elif [[ “${release}” == “ubuntu” ]]; 然后
    echo -e "${Error} ubuntu不会写，你来吧" && exit 1
  别的
    echo -e "${Error} 不支持当前系统${release} ${version} ${bit} !" && 出口 1
  菲

  BBR_grub
  echo -e "${Tip} 内核安装完毕，请参考上面的信息检查安装是否成功，默认从排第一个的高版本内核启动"
}

#检查官方xanmod主内核并安装
check_sys_official_xanmod_main() {
  检查版本
  wget -O check_x86-64_psabi.sh https://dl.xanmod.org/check_x86-64_psabi.sh
  chmod +x check_x86-64_psabi.sh
  cpu_level=$(./check_x86-64_psabi.sh | awk -F'v''{打印$2}')
  echo -e "CPU 支持 \033[32m${cpu_level}\033[0m"
  ＃ 出口
  如果 [[ ${bit} != "x86_64" ]]; 然后
    echo -e "${Error} 不支持x86_64以外的系统！" && 出口 1
  菲

  如果 [[ “${OS_type}” == “Debian” ]]; 然后
    apt 更新
    apt-get 安装 gnupg gnupg2 gnupg1 sudo -y
    echo 'deb http://deb.xanmod.org 发布 main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list
    wget -qO - https://dl.xanmod.org/gpg.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/xanmod-kernel.gpg 添加 -
    如果 [[ “${cpu_level}” == “4” ]]; 然后
      apt 更新 && apt 安装 linux-xanmod-x64v4 -y
    elif [[ “${cpu_level}” == “3” ]]; 然后
      apt 更新 && apt 安装 linux-xanmod-x64v3 -y
    elif [[ “${cpu_level}” == “2” ]]; 然后
      apt 更新 && apt 安装 linux-xanmod-x64v2 -y
    别的
      apt 更新 && apt 安装 linux-xanmod-x64v1 -y
    菲
  别的
    echo -e "${Error} 不支持当前系统${release} ${version} ${bit} !" && 出口 1
  菲

  BBR_grub
  echo -e "${Tip} 内核安装完毕，请参考上面的信息检查安装是否成功，默认从排第一个的高版本内核启动"
}

#检查官方xanmod lts内核并安装
check_sys_official_xanmod_lts() {
  检查版本
  wget -O check_x86-64_psabi.sh https://dl.xanmod.org/check_x86-64_psabi.sh
  chmod +x check_x86-64_psabi.sh
  cpu_level=$(./check_x86-64_psabi.sh | awk -F'v''{打印$2}')
  echo -e "CPU 支持 \033[32m${cpu_level}\033[0m"
  ＃ 出口
  如果 [[ ${bit} != "x86_64" ]]; 然后
    echo -e "${Error} 不支持x86_64以外的系统！" && 出口 1
  菲

  如果 [[ “${OS_type}” == “Debian” ]]; 然后
    apt 更新
    apt-get 安装 gnupg gnupg2 gnupg1 sudo -y
    echo 'deb http://deb.xanmod.org 发布 main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list
    wget -qO - https://dl.xanmod.org/gpg.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/xanmod-kernel.gpg 添加 -
    如果 [[ “${cpu_level}” == “4” ]]; 然后
      apt 更新 && apt 安装 linux-xanmod-lts-x64v4 -y
    elif [[ “${cpu_level}” == “3” ]]; 然后
      apt 更新 && apt 安装 linux-xanmod-lts-x64v3 -y
    elif [[ “${cpu_level}” == “2” ]]; 然后
      apt 更新 && apt 安装 linux-xanmod-lts-x64v2 -y
    别的
      apt 更新 && apt 安装 linux-xanmod-lts-x64v1 -y
    菲
  别的
    echo -e "${Error} 不支持当前系统${release} ${version} ${bit} !" && 出口 1
  菲

  BBR_grub
  echo -e "${Tip} 内核安装完毕，请参考上面的信息检查安装是否成功，默认从排第一个的高版本内核启动"
}

#检查官方xanmod lts内核并安装
check_sys_official_xanmod_edge() {
  检查版本
  wget -O check_x86-64_psabi.sh https://dl.xanmod.org/check_x86-64_psabi.sh
  chmod +x check_x86-64_psabi.sh
  cpu_level=$(./check_x86-64_psabi.sh | awk -F'v''{打印$2}')
  echo -e "CPU 支持 \033[32m${cpu_level}\033[0m"
  ＃ 出口
  如果 [[ ${bit} != "x86_64" ]]; 然后
    echo -e "${Error} 不支持x86_64以外的系统！" && 出口 1
  菲

  如果 [[ “${OS_type}” == “Debian” ]]; 然后
    apt 更新
    apt-get 安装 gnupg gnupg2 gnupg1 sudo -y
    echo 'deb http://deb.xanmod.org 发布 main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list
    wget -qO - https://dl.xanmod.org/gpg.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/xanmod-kernel.gpg 添加 -
    如果 [[ “${cpu_level}” == “4” ]]; 然后
      apt 更新 && apt 安装 linux-xanmod-edge-x64v4 -y
    elif [[ “${cpu_level}” == “3” ]]; 然后
      apt 更新 && apt 安装 linux-xanmod-edge-x64v3 -y
    elif [[ “${cpu_level}” == “2” ]]; 然后
      apt 更新 && apt 安装 linux-xanmod-edge-x64v2 -y
    别的
      apt 更新 && apt 安装 linux-xanmod-edge-x64v1 -y
    菲
  别的
    echo -e "${Error} 不支持当前系统${release} ${version} ${bit} !" && 出口 1
  菲

  BBR_grub
  echo -e "${Tip} 内核安装完毕，请参考上面的信息检查安装是否成功，默认从排第一个的高版本内核启动"
}

#检查Zen官方内核并安装
check_sys_official_zen（）{
  检查版本
  如果 [[ ${bit} != "x86_64" ]]; 然后
    echo -e "${Error} 不支持x86_64以外的系统！" && 出口 1
  菲
  如果 [[ “${release}” == “debian” ]]; 然后
    curl'https://liquorix.net/add-liquorix-repo.sh'| sudo bash
    apt-get 安装 linux-image-liquorix-amd64 linux-headers-liquorix-amd64 -y
  elif [[ “${release}” == “ubuntu” ]]; 然后
    如果！输入add-apt-repository> / dev / null 2>＆1;然后
      echo 'add-apt-repository 未安装安装中'
      apt-get 安装软件属性通用-y
    别的
      echo 'add-apt-repository 已安装，继续'
    菲
    添加 apt 存储库 ppa:damentz/liquorix && sudo apt-get 更新
    apt-get 安装 linux-image-liquorix-amd64 linux-headers-liquorix-amd64 -y
  别的
    echo -e "${Error} 不支持当前系统${release} ${version} ${bit} !" && 出口 1
  菲

  BBR_grub
  echo -e "${Tip} 内核安装完毕，请参考上面的信息检查安装是否成功，默认从排第一个的高版本内核启动"
}

#检查系统当前状态
检查状态() {
  内核版本=$(uname -r | awk -F“-”'{打印$1}')
  内核版本完整=$(uname -r)
  net_congestion_control = $（cat /proc/sys/net/ipv4/tcp_congestion_control | awk'{打印$ 1}'）
  net_qdisc=$(cat /proc/sys/net/core/default_qdisc | awk'{打印$1}')
  如果 [[ ${kernel_version_full} == *bbrplus* ]]; 那么
    kernel_status="BBRplus"
  elif [[ ${kernel_version_full} == *4.9.0-4* || ${kernel_version_full} == *4.15.0-30* || ${kernel_version_full} == *4.8.0-36* || ${kernel_version_full} == *3.16.0-77* || ${kernel_version_full} == *3.16.0-4* || ${kernel_version_full} == *3.2.0-4* || ${kernel_version_full} == *4.11.2-1* || ${kernel_version_full} == *2.6.32-504* || ${kernel_version_full} == *4.4.0-47* || ${kernel_version_full} == *3.13.0-29 || ${kernel_version_full} == *4.4.0-47* ]]; 然后
    kernel_status="Lotserver"
  elif [[ $(echo ${kernel_version} | awk -F'.' '{print $1}') == "4" ]] && [[ $(echo ${kernel_version} | awk -F'.' '{print $2}') -ge 9 ]] || [[ $(echo ${kernel_version} | awk -F'.' '{print $1}') == "5" ]] || [[ $(echo ${kernel_version} | awk -F'.' '{print $1}') == "6" ]]; 然后
    kernel_status="BBR"
  别的
    kernel_status="未安装"
  菲

  如果 [[ ${kernel_status} == "BBR" ]]; 那么
    run_status = $（cat /proc/sys/net/ipv4/tcp_congestion_control | awk'{打印$ 1}'）
    如果 [[ ${run_status} == "bbr" ]]; 那么
      run_status = $（cat /proc/sys/net/ipv4/tcp_congestion_control | awk'{打印$ 1}'）
      如果 [[ ${run_status} == "bbr" ]]; 那么
        run_status="BBR启动成功"
      别的
        run_status="BBR启动失败"
      菲
    elif [[ ${run_status} == "bbr2" ]]; 然后
      run_status = $（cat /proc/sys/net/ipv4/tcp_congestion_control | awk'{打印$ 1}'）
      如果 [[ ${run_status} == "bbr2" ]]; 那么
        run_status="BBR2启动成功"
      别的
        run_status="BBR2启动失败"
      菲
    elif [[ ${run_status} ==“海啸” ]]; 然后
      run_status = $（lsmod | grep“海啸”| awk'{print $1}'）
      如果 [[ ${run_status} == “tcp_tsunami” ]]; 然后
        run_status="BBR魔改版启动成功"
      别的
        run_status="BBR魔改版启动失败"
      菲
    elif [[ ${run_status} == "nanqinlang" ]]; 然后
      run_status=$(lsmod | grep "nanqinlang" | awk '{print $1}')
      如果 [[ ${run_status} == "tcp_nanqinlang" ]]; 那么
        run_status="暴力BBR魔改版启动成功"
      别的
        run_status="暴力BBR魔改版启动失败"
      菲
    别的
      run_status="未安装加速模块"
    菲

  elif [[ ${kernel_status} == "Lotserver" ]]; 然后
    如果 [[ -e /appex/bin/lotServer.sh ]]; 那么
      run_status = $（bash /appex/bin/lotServer.sh 状态 | grep“LotServer”| awk'{print $3}'）
      如果 [[ ${run_status} == "正在运行！" ]]; 然后
        run_status="启动成功"
      别的
        run_status="启动失败"
      菲
    别的
      run_status="未安装加速模块"
    菲
  elif [[ ${kernel_status} == "BBRplus" ]]; 然后
    run_status = $（cat /proc/sys/net/ipv4/tcp_congestion_control | awk'{打印$ 1}'）
    如果 [[ ${run_status} == "bbrplus" ]]; 然后
      run_status = $（cat /proc/sys/net/ipv4/tcp_congestion_control | awk'{打印$ 1}'）
      如果 [[ ${run_status} == "bbrplus" ]]; 然后
        run_status="BBRplus启动成功"
      别的
        run_status="BBRplus启动失败"
      菲
    elif [[ ${run_status} == "bbr" ]]; 然后
      run_status="BBR启动成功"
    别的
      run_status="未安装加速模块"
    菲
  菲
}

############系统检测组件############
检查系统
检查版本
[[ "${OS_type}" == "Debian" ]] && [[ "${OS_type}" == "CentOS" ]] && echo -e "${Error} 本脚本不支持当前系统 ${release} ！” && 出口 1
check_github
开始菜单
