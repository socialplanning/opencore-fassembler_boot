#!/bin/bash

# THIS SCRIPT DOES NOT TAKE CARE OF STOPPING OR CHECKING SERVICES!!!

# arguments:
# ./newbuild.sh profile_url basedir etc_svn_repo site_name base_port num_extra_zopes

BASEDIR="$2"

ETC_SVN_REPO="$3"

FASSEMBLER_EXTRAS_FILE="fassembler-req.txt"

INSTANCE="$4"

BASE_PORT="$5"

NUM_EXTRA_ZOPES="$6"

USE_WGET="$7"

if [ `uname -s` == "Darwin" ]; then
	# Unfortunately BSD sed is not fully compatible with GNU sed.
	DB_PREFIX="$(echo ${INSTANCE%.*} | sed -E 's/[^a-zA-Z0-9_]+/_/g')_"
else
	DB_PREFIX="$(echo ${INSTANCE%.*} | sed -r 's/\W+/_/g')_"
fi
echo Database prefix normalized to "$DB_PREFIX"
	
REQ_BASE="https://svn.openplans.org/svn/build/requirements"
REQ_DIR="$1"
shift

if [ -z "$REQ_DIR" ] ; then
    echo "Usage: $(basename $0) REQ_DIR [fassembler options]"
    echo "REQ_DIR is a fully-specific SVN URL (http(s)://, file://, svn://, or svn+ssh://), or a directory at least two levels below $REQ_BASE"
    echo "Available:"
    svn cat https://svn.openplans.org/svn/scripts/build/list_req_dirs.py | python
    exit 2
fi

REQ_SVN=$REQ_DIR
if [[ $REQ_DIR != http://* && $REQ_DIR != https://* && $REQ_DIR != file://* && $REQ_DIR != svn://* && $REQ_DIR != svn+ssh://* ]]; then
  REQ_SVN="$REQ_BASE/$REQ_DIR"
fi

if [ $USE_WGET == "0" ] ; then
    svn ls $REQ_SVN &> /dev/null
    if [ $? != 0 ]; then
	echo "The directory $REQ_SVN does not exist."
	echo "Available:"
	svn cat https://svn.openplans.org/svn/scripts/build/list_req_dirs.py | python
	exit 3
    fi
fi

cd ${BASEDIR}
cd builds

echo -n "downloading setuptools-0.6c11-py2.4.egg ..."
wget --no-check-certificate http://pypi.python.org/packages/2.4/s/setuptools/setuptools-0.6c11-py2.4.egg

echo -n "refreshing fassembler-boot.py..."
if [ -e fassembler-boot.py ]; then
    rm fassembler-boot.py
fi
wget --no-check-certificate https://github.com/socialplanning/fassembler/raw/master/fassembler-boot.py
chmod +x fassembler-boot.py
echo "done."

DATE=$(date +%Y%m%d)

# check for build name
N=0
DIR="$DATE"
while [ -e "$DIR" ]
do
    N=$((N+1))
    DIR="$DATE-$N"
done

./fassembler-boot.py ${DIR}
cd $DIR

FASSEMBLER_EXTRAS="$REQ_SVN/$FASSEMBLER_EXTRAS_FILE"
if [ $USE_WGET == "0" ]; then
    svn export $FASSEMBLER_EXTRAS
fi
if [ $USE_WGET == "1" ]; then
    wget --no-check-certificate $FASSEMBLER_EXTRAS
fi
if [ $? == 0 ]; then
    echo fassembler/bin/pip install -r $FASSEMBLER_EXTRAS_FILE
    fassembler/bin/pip install -r $FASSEMBLER_EXTRAS_FILE
fi

echo bin/fassembler base_port="$BASE_PORT" var="$BASEDIR/var" db_prefix=${DB_PREFIX} etc_svn_subdir=${INSTANCE} etc_svn_repo=${ETC_SVN_REPO} requirements_svn_repo="$REQ_SVN" num_extra_zopes=${NUM_EXTRA_ZOPES} requirements_use_wget=${USE_WGET} fassembler:topp
bin/fassembler base_port="$BASE_PORT" var="$BASEDIR/var" db_prefix=${DB_PREFIX} etc_svn_subdir=${INSTANCE} etc_svn_repo=${ETC_SVN_REPO} requirements_svn_repo="$REQ_SVN" num_extra_zopes=${NUM_EXTRA_ZOPES} requirements_use_wget=${USE_WGET} fassembler:topp

echo bin/fassembler etc_svn_subdir=${INSTANCE} etc_svn_repo=${ETC_SVN_REPO} missing 
bin/fassembler etc_svn_subdir=${INSTANCE} etc_svn_repo=${ETC_SVN_REPO} missing 

if [ $NUM_EXTRA_ZOPES != 0 ]; then
  echo "Building $NUM_EXTRA_ZOPES extra Zope instances.."
  for ((i=1; i<=NUM_EXTRA_ZOPES; i++))
  do
    echo bin/fassembler zope_num=${i} extrazope
    bin/fassembler zope_num=${i} extrazope
  done
fi
