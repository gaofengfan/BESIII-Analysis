if [ $# -le 1 ]; then
  echo "Usage: $0 BOSS_relase_number workarea_name"
  exit
fi

CurrentDir=`pwd`
BossRelaseNo=$1
WorkAreaDir=$1
if [ $# -ge 2 ]; then
  WorkAreaDir=$2
fi

if [ -d $WorkAreaDir ]; then
  echo WorkArea $WorkAreaDir exist
  exit
fi

echo WorkArea set to $WorkAreaDir
mkdir $WorkAreaDir
cd $WorkAreaDir
cp -r /cvmfs/bes3.ihep.ac.cn/bes3sw/cmthome/cmthome-$BossRelaseNo ./
cd cmthome-$BossRelaseNo
sed -i '/macro WorkArea/d' requirements
sed -i '/#path_remove CMTPATH  "${WorkArea}"/d' requirements
sed -i '/#path_prepend CMTPATH "${WorkArea}"/d' requirements
sed -i '44i set WorkArea "'$CurrentDir/$WorkAreaDir'"' requirements
sed -i '46i path_remove CMTPATH "/zhangyao/"' requirements
sed -i '47i path_prepend CMTPATH "${WorkArea}"' requirements
sed -i 's/maqm/bes3/' setupCVS.sh
source setupCMT.sh
cmt config
source setup.sh
source setupCVS.sh

cd $CurrentDir/$WorkAreaDir
TestReleaseVersion=`ls /cvmfs/bes3.ihep.ac.cn/bes3sw/Boss/$BossRelaseNo/TestRelease`
echo checkout TestRelease/$TestReleaseVersion
cmt co -r $TestReleaseVersion TestRelease
cd TestRelease/$TestReleaseVersion/cmt
cmt config

#source setup.sh
cd ../../../
echo `pwd`
cat>env_"$WorkAreaDir".sh<<EOF
source $CurrentDir/$WorkAreaDir/cmthome-$BossRelaseNo/setupCMT.sh
source $CurrentDir/$WorkAreaDir/cmthome-$BossRelaseNo/setupCVS.sh
source $CurrentDir/$WorkAreaDir/cmthome-$BossRelaseNo/setup.sh
source $CurrentDir/$WorkAreaDir/TestRelease/$TestReleaseVersion/cmt/setup.sh
EOF
source cmthome-$BossRelaseNo/cleanup.sh
chmod +x env_"$WorkAreaDir".sh
source env_"$WorkAreaDir".sh
echo BOSS enviroment $BossRelaseNo created in $WorkAreaDir
echo You could use $CurrentDir/$WorkAreaDir/env_"$WorkAreaDir".sh to setup this enviroment
