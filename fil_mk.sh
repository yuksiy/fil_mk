#!/bin/sh

# ==============================================================================
#   機能
#     新規ファイル/ディレクトリを作成し、オーナ・グループ・パーミッションを設定する
#   構文
#     USAGE 参照
#
#   Copyright (c) 2006-2017 Yukio Shiiya
#
#   This software is released under the MIT License.
#   https://opensource.org/licenses/MIT
# ==============================================================================

######################################################################
# 関数定義
######################################################################
PRE_PROCESS() {
	:
}

POST_PROCESS() {
	:
}

USAGE() {
	cat <<- EOF 1>&2
		Usage:
		    fil_mk.sh [OPTIONS ...] FileName...
		
		OPTIONS:
		    -m MODE
		    -o OWNER
		    -d
		       Make a directory.
		    -k
		       Make a directory with an empty ${KEEP_FILE} file in it.
		    -M KEEP_FILE_MODE
		    -O KEEP_FILE_OWNER
		    --help
		       Display this help and exit.
	EOF
}

CMD_V() {
	(eval "set -x; $*")
}

######################################################################
# 変数定義
######################################################################
LS_OPTIONS="-ald"

MODE=""									#初期状態が「空文字」でなければならない変数
OWNER=""								#初期状態が「空文字」でなければならない変数
FLAG_OPT_DIR=FALSE
FLAG_OPT_KEEP_FILE=FALSE
KEEP_FILE=".keep"						#初期状態が「空文字以外」でなければならない変数
KEEP_FILE_MODE=""						#初期状態が「空文字」でなければならない変数
KEEP_FILE_OWNER=""						#初期状態が「空文字」でなければならない変数

######################################################################
# メインルーチン
######################################################################

# オプションのチェック
CMD_ARG="`getopt -o m:o:dkM:O: -l help -- \"$@\" 2>&1`"
if [ $? -ne 0 ];then
	echo "-E ${CMD_ARG}" 1>&2
	USAGE;exit 1
fi
eval set -- "${CMD_ARG}"
while true ; do
	opt="$1"
	case "${opt}" in
	-m)	MODE="$2" ; shift 2;;
	-o)	OWNER="$2" ; shift 2;;
	-d)	FLAG_OPT_DIR=TRUE ; shift 1;;
	-k)	FLAG_OPT_KEEP_FILE=TRUE ; shift 1;;
	-M)	KEEP_FILE_MODE="$2" ; shift 2;;
	-O)	KEEP_FILE_OWNER="$2" ; shift 2;;
	--help)
		USAGE;exit 0
		;;
	--)
		shift 1;break
		;;
	esac
done

# 引数のチェック
if [ $# -eq 0 ];then
	echo "-E Missing 1st argument" 1>&2
	USAGE;exit 1
fi

# 作業開始前処理
PRE_PROCESS

#####################
# メインループ 開始 #
#####################

for arg in "$@" ; do
	dir=`dirname "${arg}"`
	file=`basename "${arg}"`

	# 既存ファイルの存在チェック
	if [ -e "${dir}/${file}" ];then
		echo "-W \"${dir}/${file}\" file exist, skipped" 1>&2
		continue
	fi

	# 新規ファイルの作成先の親ディレクトリの存在チェック
	if [ ! -d "${dir}" ];then
		# エラーメッセージを表示して異常終了
		echo "-E \"${dir}\" directory not exist, or not a directory" 1>&2
		cat 1>&2 <<- EOF
			Note:
			    This script does not support for making NEW PARENT directories.
			    If you need new parent directories, make them in advance before
			    running this script.
		EOF
		POST_PROCESS;exit 1
	fi

	# 新規ファイルの作成
	if [ "${FLAG_OPT_DIR}" = "TRUE" ];then
		CMD_V "mkdir \"${dir}/${file}\""
		if [ $? -ne 0 ];then
			echo "-E Command has ended unsuccessfully." 1>&2
			POST_PROCESS;exit 1
		fi
	else
		CMD_V "touch \"${dir}/${file}\""
		if [ $? -ne 0 ];then
			echo "-E Command has ended unsuccessfully." 1>&2
			POST_PROCESS;exit 1
		fi
	fi

	# 新規ファイルのオーナ・グループ設定
	if [ ! "${OWNER}" = "" ];then
		CMD_V "chown ${OWNER} \"${dir}/${file}\""
		if [ $? -ne 0 ];then
			echo "-E Command has ended unsuccessfully." 1>&2
			POST_PROCESS;exit 1
		fi
	else
		echo "-I OWNER not specified, chown skipped"
	fi

	# 新規ファイルのモード設定
	if [ ! "${MODE}" = "" ];then
		CMD_V "chmod ${MODE} \"${dir}/${file}\""
		if [ $? -ne 0 ];then
			echo "-E Command has ended unsuccessfully." 1>&2
			POST_PROCESS;exit 1
		fi
	else
		echo "-I MODE not specified, chmod skipped"
	fi

	# 新規ファイルのLL
	eval "ls ${LS_OPTIONS} \"${dir}/${file}\""
	if [ $? -ne 0 ];then
		echo "-E Command has ended unsuccessfully." 1>&2
		POST_PROCESS;exit 1
	fi

	if [ \( "${FLAG_OPT_DIR}" = "TRUE" \) -a \( "${FLAG_OPT_KEEP_FILE}" = "TRUE" \) ];then
		# KEEPファイルの作成
		CMD_V "touch \"${dir}/${file}/${KEEP_FILE}\""
		if [ $? -ne 0 ];then
			echo "-E Command has ended unsuccessfully." 1>&2
			POST_PROCESS;exit 1
		fi

		# KEEPファイルのオーナ・グループ設定
		if [ ! "${KEEP_FILE_OWNER}" = "" ];then
			CMD_V "chown ${KEEP_FILE_OWNER} \"${dir}/${file}/${KEEP_FILE}\""
			if [ $? -ne 0 ];then
				echo "-E Command has ended unsuccessfully." 1>&2
				POST_PROCESS;exit 1
			fi
		else
			echo "-I KEEP_FILE_OWNER not specified, chown skipped"
		fi

		# KEEPファイルのモード設定
		if [ ! "${KEEP_FILE_MODE}" = "" ];then
			CMD_V "chmod ${KEEP_FILE_MODE} \"${dir}/${file}/${KEEP_FILE}\""
			if [ $? -ne 0 ];then
				echo "-E Command has ended unsuccessfully." 1>&2
				POST_PROCESS;exit 1
			fi
		else
			echo "-I KEEP_FILE_MODE not specified, chmod skipped"
		fi

		# KEEPファイルのLL
		eval "ls ${LS_OPTIONS} \"${dir}/${file}/${KEEP_FILE}\""
		if [ $? -ne 0 ];then
			echo "-E Command has ended unsuccessfully." 1>&2
			POST_PROCESS;exit 1
		fi
	fi
done

#####################
# メインループ 終了 #
#####################

# 作業終了後処理
POST_PROCESS;exit 0

