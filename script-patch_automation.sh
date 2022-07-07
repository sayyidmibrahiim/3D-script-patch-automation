# !bin/bash

#Variabel Untuk script mengetahui nama tempat instalasi dolphin, /opt/ atau /app/ atau /dat/ dll.
installDir=$(cut -d '=' -f 2 /etc/dolphin/dolphin.conf)

#Variabel Untuk mengirimkan notifikasi ke telegram
#Token Telgeram Testing Ibrahim
chat_id="-1001777777034"
token="5282519573:AAGHiycmvlNR3q_gO2hkFR0mGv5d5XfkltE"

#Token Telegram Notificatin 3D
#chat_id="-1001442694951"
#token="5240416411:AAFLjJPBVx62ebJeHYKVuv-DNvzi8V8yB1k"

#Variabel Untuk menambil url UI client
urlC=$(grep app.ssl.driver.domain $installDir/config/resources.properties | cut -d '=' -f 2 | cut -d '/' -f 3 | cut -d ':' -f 1)

#Variabel Untuk mengecek direktori script di home/dolphin
checkFolderHomeDolphinScript=$(find /home/dolphin/ -type d -name "script"  2>/dev/null | wc -l)

#Variabel untuk mengecek direktori report-patch di /home/dolphin/script/
checkFolderReportPatch=$(find /home/dolphin/script/ -type d -name "report-patch"  2>/dev/null | wc -l)

#echo samadengan
batas1="==========================================================="

#echo pagar
batas2="###########################################################"

#penjagaan script gagal
nama_folder_object=$1

if [ -z "$nama_folder_object" ]; then
        echo -e "$batas1"
        echo -e "cara jalanin scriptnya gini"
        echo -e "./script_patch-automation nama_folder_object_patch"
        echo -e "$batas1"
        exit
fi

#penjagaan kalau nama folder ada special char "/"
nama_folder_object=$(echo "$nama_folder_object" | cut -d '/' -f 1)

#cari folder patch
posisi_script_dan_folder_object=$(pwd)
cari_folder_patch=$(find "$posisi_script_dan_folder_object/" -maxdepth 1 -type d -name "$nama_folder_object" | wc -l)

if [ "$cari_folder_patch" == 0 ]; then
        echo "folder patch gak ketemu, coba cek lagi nama foldernya!"
        exit
else
        folder_patch=$(find "$posisi_script_dan_folder_object/" -maxdepth 1 -type d -name "$nama_folder_object")
fi

#Kondisi jika direktori script tidak ada, maka buat direktori script
if [ $checkFolderHomeDolphinScript -eq 0 ]; then
    mkdir /home/dolphin/script
#Kondisi jika folder report-patch tidak ada, maka buat direktori report-patch
elif [ $checkFolderReportPatch -eq 0 ]; then
    mkdir /home/dolphin/script/report-patch
    #Command untuk membuat file report-patch.txt
    touch /home/dolphin/script/report-patch/report-patch.txt
fi

#Kondisi jika direktori dolphin sudah ada, maka langsung buat direktori report-patch
if [ ! -z "$checkFolderHomeDolphinScript" ]; then
    mkdir -p /home/dolphin/script/report-patch
    #Command untuk membuat file report-patch.txt
    touch /home/dolphin/script/report-patch/report-patch.txt
fi
#Function selection choice untuk nama support yang melakukan patching
NamaSupport () {
    local prompt="$1" outvar="$2"
    shift
    shift
    local options=("$@") cur=0 count=${#options[@]} index=0
    local esc=$(echo -en "\e") # cache ESC as test doesn't allow esc codes
    printf "$prompt\n"
    while true
    do
        # list all options (option list is zero-based)
        index=0
        for o in "${options[@]}"
        do
            if [ "$index" == "$cur" ]
            then echo -e " >\e[7m$o\e[0m" # mark & highlight the current option
            else echo "  $o"
            fi
            index=$(( $index + 1 ))
        done
        read -s -n3 key # wait for user to key in arrows or ENTER
        if [[ $key == $esc[A ]] # up arrow
        then cur=$(( $cur - 1 ))
            [ "$cur" -lt 0 ] && cur=0
        elif [[ $key == $esc[B ]] # down arrow
        then cur=$(( $cur + 1 ))
            [ "$cur" -ge $count ] && cur=$(( $count - 1 ))
        elif [[ $key == "" ]] # nothing, i.e the read delimiter - ENTER
        then break
        fi
        echo -en "\e[${count}A" # go up to the beginning to re-render
    done
    # export the selection to the requested output variable
    printf -v $outvar "${options[$cur]}"
}

#Ini optionnya
selections=( "Mas Nanto" "Mas Dani" "Mas Galih" "Hapiz" "Dimas" "Ibrahim" "Abil" "Emen" "Fadhil" "Tamar")

#Function NamaSupport di panggil disini dan masuk ke variabel selected_choice_person
echo -e "$batas1"
echo "Siapa nih yang ngpatchnya?"
echo -e "$batas1"
NamaSupport "Dipilih dipilih!!" selected_choice_person "${selections[@]}"

#Function input alasan atau tujuan ngpatchnya
ReasonPatch () {
    #Looping pertanyaan keperluan ngpatch
    while true; do
        echo -e $batas1
        echo "Untuk keperluan atau fixing apa nih ngpatchnyaaaa? "
        echo -e $batas1
        #Hasil input masuk ke variabel reason
        read reason
        #Kondisi jika variabel reason tidak kosong maka looping berhenti
        if [ ! -z "$reason" ]; then
            #Menghentikan looping while
            break
        fi
    done
}

#Function input informasi asal object patch
ObjectFrom () {
    #Looping pertanyaan informasi asal object patch
    while true; do
        echo -e $batas1
        echo "Objeknya dari mana nih masseehhh? "
        echo -e $batas1
        #Hasil input masuk ke variabel of
        read of
        #Kondisi jika variabel of tidak kosong maka looping berhenti
        if [ ! -z "$of" ]; then
            #Menghentikan looping
            break
        fi
    done
}
#Memanggil function alasan patch
ReasonPatch
#Mengabaikan signal esc
esc=$(echo -en "\e")
#Looping jika user mengklik signal esc
until [[ $reason != $esc ]]; do
    ReasonPatch
done
    ObjectFrom
#Looping jika user mengklik signal esc
until [[ $of != $esc ]]; do
    ObjectFrom
done

#Untuk membuat report-patch
echo -e "$batas1" >> /home/dolphin/script/report-patch/report-patch.txt
echo -e "Patching $urlC" >> /home/dolphin/script/report-patch/report-patch.txt
echo -e "$batas1" >> /home/dolphin/script/report-patch/report-patch.txt
echo "⇨ Nama             : $selected_choice_person" >> /home/dolphin/script/report-patch/report-patch.txt
echo "⇨ Tanggal          : $(date +'%d-%m-%y') ($(date '+%T'))" >> /home/dolphin/script/report-patch/report-patch.txt
echo "⇨ Objek From       : $of" >> /home/dolphin/script/report-patch/report-patch.txt
echo "⇨ Keperluan Patch  : $reason" >> /home/dolphin/script/report-patch/report-patch.txt
echo -e "$batas1" >> /home/dolphin/script/report-patch/report-patch.txt
echo -e "$batas2" >> /home/dolphin/script/report-patch/report-patch.txt
echo -e "$batas1"
echo -e "Report patch bisa diliat disokin! \n/home/dolphin/script/report-patch/report-patch.txt"
echo -e "$batas1"

#Text yang akan dikirimkan ke notifikasi channel telegram notification patching
text="=================================="
text="$text%0A<b>Patching Activity For $urlC</b>"
text="$text%0A=================================="
text="$text%0AExecutor       :  $selected_choice_person"
text="$text%0ADate              :  $(date +'%d-%m-%y') ($(date '+%T'))"
text="$text%0AObject From :  $of"
text="$text%0ANeeds For     :  $reason"

trap '' 2
#Curl mengirimkan notifikasi ke channel telegram notification patching
curl -s -d parse_mode=HTML -d chat_id="$chat_id" -d text="$text" https://api.telegram.org/bot$token/sendMessage > /dev/null 2>&1

list_channel_status=$(find /home/dolphin/ -name .list-channel.txt)

#Checking Channel Services
ch="conf/flume"
echo -e "$batas2"
echo -e "$batas1"
echo -e "Lagi ngecek semua channel sebelum ngpatch"
echo -e "$batas1"
#Kondisi jika variabel ch lebih besar dari pada 0, maka muncul echo peringatan dan mengeksekusi command kill channel
if (( $( jcmd | grep -i $ch | grep -v grep | wc -l) > 0 )); then
    echo -e "--> $(tput setaf 3)Lagi matiin semua channel...$(tput sgr0)"
    if [ -z $list_channel_status ]; then
    #Save state channel yang sedang aktif
    jcmd | grep -i $ch | grep -v grep |awk '{print$4}'| cut -d '/' -f 2  >> ~/.list-channel.txt
    fi
    #Command kill semua channel yang sedang aktif / on
    jcmd | grep -i $ch | grep -v grep | awk '{print$1}' | xargs kill -9 &
    #Menampilkan informasi channel selesai dimatikan
    echo -e "--> $(tput setaf 2)Selesai matiin semua channel!!$(tput sgr0)"
#Jika kondisi variabel ch salah maka command di bawah dijalankan
else
    echo -e "--> $(tput setaf 1)Gak ada channel yang lagi jalan!!$(tput sgr0)"
fi

#Checking Social Service
social="dolphin-social_lib"
echo -e "$batas1"
echo -e "Lagi ngecek service social!!"
echo -e "$batas1"
#Kondisi jika variabel social lebih besar dari pada 0, maka muncul echo peringatan dan mengeksekusi command kill social
if (( $(ps -ef | grep -i $social | grep -v grep | wc -l) > 0 )); then
    echo -e "--> $(tput setaf 3)Lagi matiin service social...$(tput sgr0)"
    #Command kill service social
    cd $installDir/bin/coordinator && ./stop-social.sh > /dev/null 2>&1
    #Menampilkan informasi social selesai dimatikan
    echo -e "--> $(tput setaf 2)Selesai matiin service social!!$(tput sgr0)"
#Jika kondisi variabel social salah maka command di bawah dijalankan
else
    echo -e "--> $(tput setaf 1)Gak ada service social yang jalan!!$(tput sgr0)"
fi

#Checking lb Service
lb="dolphin-lb_lib"
#lb="ChannelLoadBalancer"
echo -e "$batas1"
echo -e "Lagi ngecek service lb!!"
echo -e "$batas1"
#Kondisi jika variabel lb lebih besar dari pada 0, maka muncul echo peringatan dan mengeksekusi command kill lb
if (( $(ps -ef | grep -i $lb | grep -v grep | wc -l) > 0 )); then
    echo -e "--> $(tput setaf 3)Lagi matiin service lb...$(tput sgr0)"
    #Command kill lb
    cd $installDir/bin/lb/ && ./stop-lb.sh > /dev/null 2>&1
    #Menampilkan informasi lb selesai dimatikan
    echo -e "--> $(tput setaf 2)Selesai matiin service lb!!$(tput sgr0)"
#Jika kondisi variabel lb salah maka command di bawah dijalankan
else
echo -e "--> $(tput setaf 1)Gak ada service lb yang jalan!!$(tput sgr0)"
fi

#Checking replication service
rpl="dolphin-replicate_lib"
echo -e "$batas1"
echo -e "Lagi ngecek service replication!!"
echo -e "$batas1"
#Kondisi jika variabel rpl lebih besar dari pada 0, maka muncul echo peringatan dan mengeksekusi command kill replicate
if (( $(ps -ef | grep -i $rpl | grep -v grep | wc -l) > 0 )) ; then
    echo -e "--> $(tput setaf 3)Lagi matiin service replication...$(tput sgr0)"
    #Command Kill replicate
    cd $installDir/bin/replication/ && ./stop-replication.sh > /dev/null 2>&1
    #Menampilkan informasi replicate selesai dimatikan
    echo -e "--> $(tput setaf 2)Selesai matiin service replication!!$(tput sgr0)"
#Jika kondisi variabel rpl salah maka command di bawah dijalankan
else
echo -e "--> $(tput setaf 1)Gak ada service replication yang jalan!!$(tput sgr0)"
fi

#Checking scheduler service
sch="dolphin-sched_lib"
echo -e "$batas1"
echo -e "Lagi ngecek service scheduler!!"
echo -e "$batas1"
#Kondisi jika variabel sch lebih besar dari pada 0, maka muncul echo peringatan dan mengeksekusi command kill scheduler
if (( $(ps -ef | grep -i $sch | grep -v grep | wc -l) > 0 )) ; then
    echo -e "--> $(tput setaf 3)Lagi matiin service scheduler...$(tput sgr0)"
    #Command kill scheduler
    cd $installDir/bin/scheduler/ && ./stop-scheduler.sh > /dev/null 2>&1
    #Menampilkan informasi scheduler selesai dimatikan
    echo -e "--> $(tput setaf 2)Selesai matiin service scheduler!!$(tput sgr0)"
#Jika kondisi variabel sch salah maka command di bawah dijalankan
else
echo -e "--> $(tput setaf 1)Gak ada service scheduler yang jalan!!$(tput sgr0)"
fi

#Checking gateway service
gt="dolphin-gateway_lib"
echo -e "$batas1"
echo -e "Lagi ngecek service gateway!!"
echo -e "$batas1"
#Kondisi jika variabel gt lebih besar dari pada 0, maka muncul echo peringatan dan mengeksekusi command kill gateway
if (( $(ps -ef | grep -i $gt | grep -v grep | wc -l) > 0 )) ; then
    echo -e "--> $(tput setaf 3)Lagi matiin service gateway...$(tput sgr0)"
    #Command kill gateway
    cd $installDir/bin/gateway/ && ./stop-gateway.sh > /dev/null 2>&1
    #Menampilkan informasi gateway selesai dimatiin
    echo -e "--> $(tput setaf 2)Selesai matiin service gateway!!$(tput sgr0)"
#Jika kondisi variabel gt salah maka command di bawah ini dijalankan
else
echo -e "--> $(tput setaf 1)Gak ada service gateway yang jalan!!$(tput sgr0)"
fi

#Checking broadcast service
bc="dolphin-broadcast_lib"
echo -e "$batas1"
echo -e "Lagi ngecek service broadcast!!"
echo -e "$batas1"
#Kondisi jika variabel bc lebih besar dari pada 0, maka muncul echo peringatan dan mengeksekusi command kill broadcast
if (( $(ps -ef | grep -i $bc | grep -v grep | wc -l) > 0 )) ; then
    echo -e "--> $(tput setaf 3)Lagi matiin service broadcast...$(tput sgr0)"
    #Command kill broadcast
    cd $installDir/bin/broadcast/ && ./stop-broadcast.sh > /dev/null 2>&1
    #Menampilkan informasi broadcast selesai dimatiin
    echo -e "--> $(tput setaf 2)Selesai matiin service broadcast!!$(tput sgr0)"
#Jika kondisi variabel bc salah maka command di bawah ini dijalankan
else
echo -e "--> $(tput setaf 1)Gak ada service broadcast yang jalan!!$(tput sgr0)"
fi

#Checking classifier service
cf="dolphin-learning_lib"
echo -e "$batas1"
echo -e "Lagi ngecek service learning!!"
echo -e "$batas1"
#Kondisi jika variabel cf lebih besar dari pada 0, maka muncul echo peringatan dan mengeksekusi command kill learning
if (( $(ps -ef | grep -i $cf | grep -v grep | wc -l) > 0 )) ; then
    echo -e "--> $(tput setaf 3)Lagi matiin service learning...$(tput sgr0)"
    #Command kill learing/classifier
    cd $installDir/bin/classifier/ && ./stop-learning.sh > /dev/null 2>&1
    #Menampilkan informasi learning/classifier selesai dimatiin
    echo -e "--> $(tput setaf 2)Selesai matiin service learning!!$(tput sgr0)"
#Jika kondisi variabel cf salah maka command di bawah ini dijalankan
else
echo -e "--> $(tput setaf 1)Gak ada service learning yang jalan!!$(tput sgr0)"
fi

#Checking meet service
mt="dolphin-zoom_lib"
echo -e "$batas1"
echo -e "Lagi ngecek service zoom/meeting!!"
echo -e "$batas1"
#Kondisi jika variabel mt lebih besar dari pada 0, maka muncul echo peringatan dan mengeksekusi command kill meet
if (( $(ps -ef | grep -i $mt | grep -v grep | wc -l) > 0 )) ; then
    echo -e "--> $(tput setaf 3)Lagi matiin service meet/zoom...$(tput sgr0)"
    #Command kill meet/zoom
    ps -ef | grep -i $mt | grep -v grep | awk '{print$2}' | xargs kill -9 &
    #Menampilkan informasi meet/zoom selesai dimatiin
    echo -e "--> $(tput setaf 2)Selesai matiin service meet/zoom!!$(tput sgr0)"
#Jika kondisi variabel mt salah maka command di bawah ini dijalankan
else
    echo -e "--> $(tput setaf 1)Gak ada service meet/zoom yang jalan!!$(tput sgr0)"
fi

#Checking UI service
ui="/bin/bootstrap.jar"
echo -e "$batas1"
echo -e "Lagi ngecek dolphin ui yang jalan!!"
echo -e "$batas1"
#Kondisi jika variabel ui lebih besar dari pada 0, maka muncul echo peringatan dan mengeksekusi command kill semua dolphin-ui
if (( $(ps -ef | grep -i $ui | grep -v grep | wc -l) > 0 )) ; then
    echo -e "--> $(tput setaf 3)Lagi matiin dolphin ui...$(tput sgr0)"
    #Command kill dolphin-ui
    ps -ef | grep -i $ui | grep -v grep | awk '{print$2}' | xargs kill -9 &
    #Menampilkan informasi dolphin-ui selesai dimatiin
    echo -e "--> $(tput setaf 2)Selesai matiin dolphin ui!!$(tput sgr0)"
#Jika kondisi variabel ui salah maka command di bawah ini dijalankan
else
    echo -e "--> $(tput setaf 1)Gak ada dolphin ui yang lagi jalan!!$(tput sgr0)"
fi

#Informasi kalau semua service sudah dimatiin
echo -e "$batas1"
echo -e "Udah selesai nih ngecek dan matiin semua servicenya."
echo -e "$batas1"
echo -e "$batas2"

#Informasi kalau mulai proses patching
echo -e "$batas1"
echo -e "Mulai ngpatch objek terbaru"

#Mengabaikan signal ctrl+C
trap '' 2

#Membuat direktori backup object sebelum patch
cd $folder_patch
mkdir -p backupObject-$(date +%Y%m%d)
folder_backup=$folder_patch/backupObject-$(date +%Y%m%d)

#Variabel untuk mencari tahu berapa dolphin-web/UI yang berjalan
find1=$(find $installDir -name dolphin-w* |  awk 'NR==1{print$1}' | cut -d '/' -f 4)
find2=$(find $installDir -name dolphin-w* |  awk 'NR==2{print$1}' | cut -d '/' -f 4)
find3=$(find $installDir -name dolphin-w* |  awk 'NR==3{print$1}' | cut -d '/' -f 4)
find4=$(find $installDir -name dolphin-w* |  awk 'NR==4{print$1}' | cut -d '/' -f 4)
findv=$(find $installDir -name dolphin-w* | wc -l)

echo -e "$batas1"
echo -e "--> $(tput setaf 3)Backup objek yang lama dulu!!$(tput sgr0)"
echo -e "$batas1"

#Backup object lama agar dapat di rolling patch jika terjadi sesuatu yang tidak diinginkan
cp $installDir/bin/coordinator/dolphin-*.jar $folder_backup 2>/dev/null
cp $installDir/bin/broadcast/dolphin-*.jar $folder_backup 2>/dev/null
cp $installDir/bin/scheduler/dolphin-*.jar $folder_backup 2>/dev/null
cp $installDir/bin/classifier/dolphin-*.jar $folder_backup 2>/dev/null
cp $installDir/bin/replication/dolphin-*.jar $folder_backup 2>/dev/null
cp $installDir/bin/lb/dolphin-*.jar $folder_backup 2>/dev/null
cp $installDir/bin/meeting/dolphin-*.jar $folder_backup 2>/dev/null
cp $installDir/bin/gateway/dolphin-*.jar $folder_backup 2>/dev/null
cp $installDir/channel/plugins.d/dolphin/lib/dolphin-*.jar $folder_backup 2>/dev/null
cp $installDir/$find1/webapps/dolphin.war $folder_backup 2>/dev/null

echo -e "--> $(tput setaf 3)Hapus objek sebelumnya!!$(tput sgr0)"
echo -e "$batas1"

#Hapus object dolphin.war dan direktory dolphin
if [ $findv -eq 1 ]; then
    rm -rf $installDir/$find1/webapps/dolphin 2>/dev/null
    rm -rf $instalDir/$find1/webapps/dolphin.war 2>/dev/null
else
    if [ $findv -eq 2 ]; then
        rm -rf $installDir/$find1/webapps/dolphin 2>/dev/null
        rm -rf $instalDir/$find1/webapps/dolphin.war 2>/dev/null
        rm -rf $installDir/$find2/webapps/dolphin 2>/dev/null
        rm -rf $instalDir/$find2/webapps/dolphin.war 2>/dev/null
    else
        rm -rf $installDir/$find1/webapps/dolphin 2>/dev/null
        rm -rf $instalDir/$find1/webapps/dolphin.war 2>/dev/null
        rm -rf $installDir/$find2/webapps/dolphin 2>/dev/null
        rm -rf $instalDir/$find2/webapps/dolphin.war 2>/dev/null
        rm -rf $installDir/$find3/webapps/dolphin 2>/dev/null
        rm -rf $instalDir/$find3/webapps/dolphin.war 2>/dev/null
    fi
fi

echo -e "--> $(tput setaf 3)Lagi proses patch objek /bin/ terbaru!!$(tput sgr0)"
echo -e "$batas1"

#Proses patch object terbaru
cp $folder_patch/dolphin-classify.jar $installDir/bin/classifier/ 2>/dev/null
cp $folder_patch/dolphin-domain.jar $installDir/bin/classifier/ 2>/dev/null
cp $folder_patch/dolphin-dialog.jar $installDir/bin/classifier/ 2>/dev/null
cp $folder_patch/dolphin-bot.jar $installDir/bin/classifier/ 2>/dev/null
cp $folder_patch/dolphin-encoder.jar $installDir/bin/classifier/ 2>/dev/null
cp $folder_patch/dolphin-learning.jar $installDir/bin/classifier/ 2>/dev/null
cp $folder_patch/dolphin-social.jar $installDir/bin/coordinator/ 2>/dev/null
cp $folder_patch/dolphin-sched.jar $installDir/bin/scheduler/ 2>/dev/null
cp $folder_patch/dolphin-broadcast.jar $installDir/bin/broadcast/ 2>/dev/null
cp $folder_patch/dolphin-replicate.jar $installDir/bin/replication/ 2>/dev/null
cp $folder_patch/dolphin-lb.jar $installDir/bin/lb/ 2>/dev/null
cp $folder_patch/dolphin-zoom.jar $installDir/bin/meeting/ 2>/dev/null
cp $folder_patch/dolphin-gateway.jar $installDir/bin/gateway/ 2>/dev/null

echo -e "--> $(tput setaf 3)Lagi proses patch objek /plugins.d/ terbaru!!$(tput sgr0)"
echo -e "$batas1"

cp $folder_patch/dolphin-bot.jar $installDir/channel/plugins.d/dolphin/lib/ 2>/dev/null
cp $folder_patch/dolphin-core.jar $installDir/channel/plugins.d/dolphin/lib/ 2>/dev/null
cp $folder_patch/dolphin-flume.jar $installDir/channel/plugins.d/dolphin/lib/ 2>/dev/null
cp $folder_patch/dolphin-mle.jar $installDir/channel/plugins.d/dolphin/lib/ 2>/dev/null
cp $folder_patch/dolphin-store.jar $installDir/channel/plugins.d/dolphin/lib/ 2>/dev/null

#Proses patch object terbaru dolphin.war jika terdapat dolphin-web lebih dari 1
if [ $findv -eq 1 ]; then
        echo -e "--> $(tput setaf 3)Lagi proses patch objek dolphin.war terbaru!!$(tput sgr0)"
        echo -e "$batas1"
        cp $folder_patch/dolphin.war $installDir/$find1/webapps/ 2>/dev/null
else
if [ $findv -eq 2 ]; then
        echo -e "--> $(tput setaf 3)Lagi proses patch objek dolphin.war terbaru!!$(tput sgr0)"
        echo -e "$batas1"
        cp $folder_patch/dolphin.war $installDir/$find1/webapps/ 2>/dev/null
        cp $folder_patch/dolphin.war $installDir/$find2/webapps/ 2>/dev/null
else
        echo -e "--> $(tput setaf 3)Lagi proses patch objek dolphin.war terbaru!!$(tput sgr0)"
        echo -e "$batas1"
        cp $folder_patch/dolphin.war $installDir/$find1/webapps/ 2>/dev/null
        cp $folder_patch/dolphin.war $installDir/$find2/webapps/ 2>/dev/null
        cp $folder_patch/dolphin.war $installDir/$find3/webapps/ 2>/dev/null
fi
fi

echo -e "Udah selesai ngpatchnya nih!!"
echo -e "$batas1"
echo -e "$batas2"
echo -e "$batas1"

#flush memcached
check=$(netstat -tuln | grep 11211)

echo "--> $(tput setaf 3)Proses flush_all memcached$(tput sgr0)"
if [ ! -z "$check" ]; then
        echo 'flush_all' | nc localhost 11211 > /dev/null 2>&1
        echo "--> $(tput setaf 2)Memcached berhasil di flush!!$(tput sgr0)"
else
        echo "--> $(tput setaf 1)Tidak ada service memcached disini!$(tput sgr0)"
        sleep 0.1
fi

echo -e "$batas1"
echo -e "$batas2"
echo -e "$batas1"
echo -e "Mulai nyalain dolphin ui"
echo -e "$batas1"
#Variabel untuk mencari hiden file .list-service yang berguna untuk membuat state service yang akan dinaikan secara otomatis nanti
testList=$(find /home/ -name .list-service.txt 2>/dev/null)
#Path pasti dari file .list-service
pathfile="/home/dolphin/.list-service.txt"

#Function untuk membuat progres bar ala ala ketika sedang menunggu dolphin-web benar benar sudah nyala
CheckUIsatu () {
echo -ne '--------------------------[00%]\r'
while true; do
#Variabel untuk mengecek log catalina.out ketika sedang proses mengaktifkan dolphin-ui
log=$(tail -n5 $installDir/$find1/logs/catalina.out | grep "org.apache.catalina.startup.HostConfig.deployWAR")
    #Kondisi jika variabel log adalah tidak kosong maka looping diberhentikan
    if [ ! -z "$log" ]; then
        break
        echo $log
    fi
done
echo -ne '##############------------[60%]\r'
while true; do
#Variabel untuk mengecek log catalina.out ketika sedang proses mengaktifkan dolphin-ui
log=$(tail -n5 $installDir/$find1/logs/catalina.out | grep "Server startup in")
    #Kondisi jika variabel log adalah tidak kosong maka looping diberhentikan
    if [ ! -z "$log" ]; then
        break
        echo $log
    fi
done
echo -ne '##########################[100%]\r'
}

#Function progres bar ala ala juga, jika terdapat dolphin-web lebih dari 1
CheckUIdua_log () {
echo -ne '--------------------------[00%]\r'
while true; do
#Variabel untuk mengecek log catalina.out ketika sedang proses mengaktifkan dolphin-ui
log=$(tail -n5 $installDir/$find2/logs/catalina.out | grep "org.apache.catalina.startup.HostConfig.deployWAR")
    #Kondisi jika variabel log adalah tidak kosong maka looping diberhentikan
    if [ ! -z "$log" ]; then
        break
        echo $log
    fi
done
echo -ne '##############------------[60%]\r'

while true; do
#Variabel untuk mengecek log catalina.out ketika sedang proses mengaktifkan dolphin-ui
log=$(tail -n5 $installDir/$find2/logs/catalina.out | grep "Server startup in")
    #Kondisi jika variabel log adalah tidak kosong maka looping diberhentikan
    if [ ! -z "$log" ]; then
        break
        echo $log
    fi
done
echo -ne '##########################[100%]\r'
}

#Function progres bar ala ala juga, jika terdapat dolphin-web lebih dari 1
CheckUItiga_log () {
echo -ne '--------------------------[00%]\r'
while true; do
#Variabel untuk mengecek log catalina.out ketika sedang proses mengaktifkan dolphin-ui
log=$(tail -n5 $installDir/$find3/logs/catalina.out | grep "org.apache.catalina.startup.HostConfig.deployWAR")
    #Kondisi jika variabel log adalah tidak kosong maka looping diberhentikan
    if [ ! -z "$log" ]; then
        break
        echo $log
    fi
done
echo -ne '##############------------[60%]\r'

while true; do
#Variabel untuk mengecek log catalina.out ketika sedang proses mengaktifkan dolphin-ui
log=$(tail -n5 $installDir/$find3/logs/catalina.out | grep "Server startup in")
    #Kondisi jika variabel log adalah tidak kosong maka looping diberhentikan
    if [ ! -z "$log" ]; then
        break
        echo $log
    fi
done
echo -ne '##########################[100%]\r'
}

#Function naikin UI manual jika file .list-service tidak ditemukan atau tidak ada
naikinUImanual () {
touch $pathfile
#Jika direktori UI cuman 1 maka command kondisi pertama dijalankan
if [ $findv -eq 1 ]; then
    #Looping pertanyaan
    while true; do
        read -p "--> $(tput setaf 3)Konfirmasi Running UI $find1$(tput sgr0) [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] $(tput setaf 3)?$(tput sgr0) "  yn
        case $yn in
            [Yy]* ) $installDir/$find1/bin/startup.sh > /dev/null 2>&1
                    echo -e "$batas1"
                    echo -e "$(tput setaf 1)Note:$(tput sgr0)"
                    echo "UI lagi proses naik, tunggu dulu sbntar yak"
                    echo -e "Atau buka tab baru buat cek log catalina.out nya!!"
                    echo "1,$find1=true" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                    break;;
            [Nn]* ) echo "1,$find1=false" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                    echo -e "$batas1"
                    break;;
                #Jika menerima input selain Yy/Nn maka akan looping sampai menerima input yang telah ditentukan
                * ) echo -e "Pilih [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] !!!\n";;
        esac
    done
#Jika direktori UI ada 2 maka command kondisi kedua dijalankan dijalankan
elif [ $findv -eq 2 ]; then
    #Looping pertanyaan direktori dolphin-ui pertama
    while true; do
        read -p "--> $(tput setaf 3)Konfirmasi Running UI $find1$(tput sgr0) [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] $(tput setaf 3)?$(tput sgr0) " yn
        case $yn in
            [Yy]* ) $installDir/$find1/bin/startup.sh  > /dev/null 2>&1
                    echo -e "$batas1"
                    echo -e "$(tput setaf 1)Note:$(tput sgr0)"
                    echo "UI lagi proses naik, tunggu dulu sbntar yak"
                    echo -e "Atau buka tab baru buat cek log catalina.out nya!!"
                    echo "1,$find1=true" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                    break;;
            [Nn]* ) echo "1,$find1=false" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                    break;;
                #Jika menerima input selain Yy/Nn maka akan looping sampai menerima input yang telah ditentukan
                * ) echo -e "Pilih [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] !!!";;
        esac
    done
    #Looping pertanyaan direktori dolphin-ui kedua
    while true; do
        echo -e "$batas1"
        read -p "--> $(tput setaf 3)Konfirmasi Running UI $find2$(tput sgr0) [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] $(tput setaf 3)?$(tput sgr0) " yn
        case $yn in
            [Yy]* ) $installDir/$find2/bin/startup.sh  > /dev/null 2>&1
                    echo -e "$batas1"
                    echo -e "$(tput setaf 1)Note:$(tput sgr0)"
                    echo "UI lagi proses naik, tunggu dulu sbntar yak"
                    echo -e "Atau buka tab baru buat cek log catalina.out nya!!"
                    echo -e "$batas1"
                    echo "2,$find2=true" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                    break;;
            [Nn]* ) echo "2,$find2=false" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                    echo -e "$batas1"
                    break;;
                #Jika menerima input selain Yy/Nn maka akan looping sampai menerima input yang telah ditentukan
                * ) echo -e "Pilih [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] !!!\n";;
        esac
    done
#Jika direktori UI ada 2 maka command kondisi kedua dijalankan dijalankan
elif [ $findv -eq 3 ]; then
    #Looping pertanyaan direktori dolphin-web pertama
    while true; do
        read -p "--> $(tput setaf 3)Konfirmasi Running UI $find1$(tput sgr0) [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] $(tput setaf 3)?$(tput sgr0) " yn
        case $yn in
            [Yy]* ) $installDir/$find1/bin/startup.sh  > /dev/null 2>&1
                    echo -e "$batas1"
                    echo -e "$(tput setaf 1)Note:$(tput sgr0)"
                    echo "UI lagi proses naik, tunggu dulu sbntar yak"
                    echo -e "Atau buka tab baru buat cek log catalina.out nya!!"
                    echo "1,$find1=true" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                    break;;
            [Nn]* ) echo "1,$find1=false" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                    break;;
                #Jika menerima input selain Yy/Nn maka akan looping sampai menerima input yang telah ditentukan
                * ) echo -e "Pilih [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] !!!\n";;
        esac
    done
    #Looping pertanyaan direktori dolphin-web kedua
    while true; do
        echo -e "$batas1"
        read -p "--> $(tput setaf 3)Konfirmasi Running UI $find2$(tput sgr0) [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] $(tput setaf 3)?$(tput sgr0) " yn
        case $yn in
            [Yy]* ) $installDir/$find2/bin/startup.sh  > /dev/null 2>&1
                    echo -e "$batas1"
                    echo -e "$(tput setaf 1)Note:$(tput sgr0)"
                    echo "UI lagi proses naik, tunggu dulu sbntar yak"
                    echo -e "Atau buka tab baru buat cek log catalina.out nya!!"
                    echo "2,$find2=true" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                    break;;
            [Nn]* ) echo "2,$find2=false" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                    break;;
                #Jika menerima input selain Yy/Nn maka akan looping sampai menerima input yang telah ditentukan
                * ) echo -e "Pilih [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] !!!\n";;
        esac
    done
    #Looping pertanyaan direktori dolphin-web ketiga
    while true; do
        echo -e "$batas1"
        read -p "$(tput setaf 3)--> Konfirmasi Running UI $find3$(tput sgr0) [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] $(tput setaf 3)?$(tput sgr0) " yn
        case $yn in
            [Yy]* ) $installDir/$find3/bin/startup.sh  > /dev/null 2>&1
                    echo -e "$batas1"
                    echo -e "$(tput setaf 1)Note:$(tput sgr0)"
                    echo "UI lagi proses naik, tunggu dulu sbntar yak"
                    echo -e "Atau buka tab baru buat cek log catalina.out nya!!"
                    echo -e "$batas1"
                    echo "3,$find3=true" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                    break;;
            [Nn]* ) echo "3,$find3=false" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                    echo -e "$batas1"
                    break;;
                #Jika menerima input selain Yy/Nn maka akan looping sampai menerima input yang telah ditentukan
                * ) echo -e "Pilih [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] !!!\n";;
        esac
    done
fi
}

#Function untuk menaikan dolphin-web secara automatis, berdasarkan state yang di simpan di file .list-service.txt di /home/dolphin
naikinUIauto () {
ui1=$(grep "1,$find1" $pathfile | cut -d '=' -f 2)
ui2=$(grep "2,$find2" $pathfile | cut -d '=' -f 2)
ui3=$(grep "3,$find3" $pathfile | cut -d '=' -f 2)
#Kondisi untuk mengecek state di file .list-service.txt apakah value dolphin-web true/false
if [[ $ui1 == true ]]; then
    #Jika valuenya true maka script akan menjalan kan dolphin-web/startup.sh
    echo "--> $(tput setaf 3)Mulai jalanin $find1 ...$(tput sgr0)"
    $installDir/$find1/bin/startup.sh > /dev/null 2>&1
    echo -e "$batas1"
    echo -e "$(tput setaf 1)Note:$(tput sgr0)"
    echo "UI lagi proses naik, tunggu dulu sbntar yak"
    echo -e "Atau buka tab baru buat cek log catalina.out nya!!"
    echo -e "$batas1"
#Jika variabel tidak ditemukan atau value variabelnya false maka akan lewat saja ke command selanjutnya
elif  [[ -z $ui1 || $ui1 == false ]]; then
    sleep 0.1
fi
#Kondisi untuk mengecek state di file .list-service.txt apakah value dolphin-web true/false
if [[ $ui2 == true ]]; then
    #Jika valuenya true maka script akan menjalan kan dolphin-web/startup.sh
    echo "--> $(tput setaf 3)Mulai jalanin $find2 ...$(tput sgr0)"
    $installDir/$find2/bin/startup.sh > /dev/null 2>&1
    echo -e "$batas1"
    echo -e "$(tput setaf 1)Note:$(tput sgr0)"
    echo "UI lagi proses naik, tunggu dulu sbntar yak"
    echo -e "Atau buka tab baru buat cek log catalina.out nya!!"
    echo -e "$batas1"
#Jika variabel tidak ditemukan atau value variabelnya false maka akan lewat saja ke command selanjutnya
elif [[ -z $ui2 || $ui2 == false ]]; then
    sleep 0.1
fi
#Kondisi untuk mengecek state di file .list-service.txt apakah value dolphin-web true/false
if [[ $ui3 == true ]]; then
    #Jika valuenya true maka script akan menjalan kan dolphin-web/startup.sh
    echo "--> $(tput setaf 3)Mulai jalanin $find3 ...$(tput sgr0)"
    $installDir/$find3/bin/startup.sh > /dev/null 2>&1
    echo -e "$batas1"
    echo -e "$(tput setaf 1)Note:$(tput sgr0)"
    echo "UI lagi proses naik, tunggu dulu sbntar yak"
    echo -e "Atau buka tab baru buat cek log catalina.out nya!!"
    echo -e "$batas1"
#Jika variabel tidak ditemukan atau value variabelnya false maka akan lewat saja ke command selanjutnya
elif  [[ -z $ui3 || $ui3 == false ]]; then
    sleep 0.1
fi
}

#Function naikin service yang ada di bin secara manual
naikinBinManual () {
echo -e "$batas1"
echo -e "Mulai nyalain service yang ada di /bin/"
echo -e "$batas1"
#Looping pertanyaan apakah service dibawah ini akan dinyalakan
file=$(grep "coordinator" $pathfile | cut -d '=' -f 2)
while true; do
    read -p "--> $(tput setaf 3)Konfirmasi Running Social$(tput sgr0) [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] $(tput setaf 3)?$(tput sgr0) " yn
    case $yn in
        [Yy]* ) cd $installDir/bin/coordinator > /dev/null 2>&1 && ./start-social.sh > /dev/null 2>&1
                sleep 5
                echo "coordinator=true" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                if (( $( jcmd | grep -i 14000 | grep -v grep | wc -l) > 0 )) ; then
                        echo "--> $(tput setaf 2)Selesai naikin service social$(tput sgr0)"
                        echo -e "$batas1"
                else
                        echo -e "--> $(tput setaf 1)Socialnya gak naek nih!!$(tput sgr0)"
                        echo -e "$batas1"
                fi
                break;;
        [Nn]* ) echo "coordinator=false" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                echo -e "$batas1"
                break;;
            * ) echo -e "Pilih [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] !!!\n";;
    esac
done

#Looping pertanyaan apakah service dibawah ini akan dinyalakan
file=$(grep "replication" $pathfile | cut -d '=' -f 2)
while true; do
    read -p "--> $(tput setaf 3)Konfirmasi Running Replication$(tput sgr0) [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] $(tput setaf 3)?$(tput sgr0) " yn
    case $yn in
        [Yy]* ) cd $installDir/bin/replication > /dev/null 2>&1 && ./start-replication.sh > /dev/null 2>&1
                sleep 5
                echo "replication=true" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                if (( $(ps -ef | grep -i $rpl | grep -v grep | wc -l) > 0 )) ; then
                        echo -e "--> $(tput setaf 2)Selesai naikin service replication$(tput sgr0)"
                        echo -e "$batas1"
                else
                        echo -e "--> $(tput setaf 1)Replicationnyaa gak naek nih!!$(tput sgr0)"
                        echo -e "$batas1"
                fi
                break;;
        [Nn]* ) echo "replication=false" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                echo -e "$batas1"
                break;;
            * ) echo -e "Pilih [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] !!!\n";;
    esac
done

#Looping pertanyaan apakah service dibawah ini akan dinyalakan
file=$(grep "lb" $pathfile | cut -d '=' -f 2)
while true; do
    read -p "--> $(tput setaf 3)Konfirmasi Running LB$(tput sgr0) [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] $(tput setaf 3)?$(tput sgr0) " yn
    case $yn in
        [Yy]* ) cd $installDir/bin/lb > /dev/null 2>&1 && ./start-lb.sh > /dev/null 2>&1
                sleep 5
                echo "lb=true" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                if (( $(ps -ef | grep -i $social | grep -v grep | wc -l) > 0 )) ; then
                        echo -e "--> $(tput setaf 2)Selesai naikin service lb$(tput sgr0)"
                        echo -e "$batas1"
                else
                        echo -e "--> $(tput setaf 1)Lbnyaa gak naek nih!!$(tput sgr0)"
                        echo -e "$batas1"
                fi
                break;;
        [Nn]* ) echo "lb=false" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                echo -e "$batas1"
                break;;
            * ) echo -e "Pilih [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] !!!\n";;
    esac
done

#Looping pertanyaan apakah service dibawah ini akan dinyalakan
file=$(grep "broadcast" $pathfile | cut -d '=' -f 2)
while true; do
    read -p "--> $(tput setaf 3)Konfirmasi Running Broadcast$(tput sgr0) [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] $(tput setaf 3)?$(tput sgr0) " yn
    case $yn in
        [Yy]* ) cd $installDir/bin/broadcast > /dev/null 2>&1 && ./start-broadcast.sh > /dev/null 2>&1
                sleep 5
                echo "broadcast=true" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                if (( $(ps -ef | grep -i $bc | grep -v grep | wc -l) > 0 )) ; then
                        echo -e "--> $(tput setaf 2)Selesai naikin service broadcast$(tput sgr0)"
                        echo -e "$batas1"
                else
                        echo -e "--> $(tput setaf 1)Broadcastnyaa gak naek nih!!$(tput sgr0)"
                        echo -e "$batas1"
                fi
                break;;
        [Nn]* ) echo "broadcast=false" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                echo -e "$batas1"
                break;;
            * ) echo -e "Pilih [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] !!!\n";;
    esac
done

#Looping pertanyaan apakah service dibawah ini akan dinyalakan
file=$(grep "learning" $pathfile | cut -d '=' -f 2)
while true; do
    read -p "--> $(tput setaf 3)Konfirmasi Running Classifier(Learning)$(tput sgr0) [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] $(tput setaf 3)?$(tput sgr0) " yn
    case $yn in
        [Yy]* ) cd $installDir/bin/classifier > /dev/null 2>&1 && ./start-learning.sh > /dev/null 2>&1
                sleep 5
                echo "learning=true" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                if (( $(ps -ef | grep -i $cf | grep -v grep | wc -l) > 0 )) ; then
                        echo "--> $(tput setaf 2)Selesai naikin service learning$(tput sgr0)"
                        echo -e "$batas1"
                else
                        echo -e "--> $(tput setaf 1)Learningnyaa gak naek nih!!$(tput sgr0)"
                        echo -e "$batas1"
                fi
                break;;
        [Nn]* ) echo "learning=false" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                echo -e "$batas1"
                break;;
            * ) echo -e "Pilih [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] !!!\n";;
    esac
done

#Looping pertanyaan apakah service dibawah ini akan dinyalakan
file=$(grep "meeting" $pathfile | cut -d '=' -f 2)
while true; do
    read -p "--> $(tput setaf 3)Konfirmasi Running Meeting$(tput sgr0) [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] $(tput setaf 3)?$(tput sgr0) " yn
    case $yn in
        [Yy]* ) cd $installDir/bin/meeting > /dev/null 2>&1 && ./start-meeting.sh > /dev/null 2>&1
                sleep 5
                echo "meeting=true" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                if (( $(ps -ef | grep -i $mt | grep -v grep | wc -l) > 0 )) ; then
                        echo "--> $(tput setaf 2)Selesai naikin service meeting$(tput sgr0)"
                        echo -e "$batas1"
                else
                        echo -e "--> $(tput setaf 1)Meetingnyaa gak naek nih!!$(tput sgr0)"
                        echo -e "$batas1"
                fi
                break;;
        [Nn]* ) echo "meeting=false" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                echo -e "$batas1"
                break;;
            * ) echo -e "Pilih [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] !!!\n";;
    esac
done

#Looping pertanyaan apakah service dibawah ini akan dinyalakan
file=$(grep "scheduler" $pathfile | cut -d '=' -f 2)
while true; do
    read -p "--> $(tput setaf 3)Konfirmasi Running Scheduler$(tput sgr0) [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] $(tput setaf 3)?$(tput sgr0) " yn
    case $yn in
        [Yy]* ) cd $installDir/bin/scheduler > /dev/null 2>&1 && ./start-scheduler.sh > /dev/null 2>&1
                sleep 5
                echo "scheduler=true" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                if (( $(ps -ef | grep -i $sch | grep -v grep | wc -l) > 0 )) ; then
                        echo "--> $(tput setaf 2)Selesai naikin service scheduler$(tput sgr0)"
                        echo -e "$batas1"
                else
                        echo -e "--> $(tput setaf 1)Schedulernyaa gak naek nih!!$(tput sgr0)"
                        echo -e "$batas1"
                fi
                break;;
        [Nn]* ) echo "scheduler=false" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                echo -e "$batas1"
                break;;
            * ) echo "Pilih Y atau N!!!";;
    esac
done

#Looping pertanyaan apakah service dibawah ini akan dinyalakan
file=$(grep "gateway" $pathfile | cut -d '=' -f 2)
while true; do
    read -p "--> $(tput setaf 3)Konfirmasi Running Gateway$(tput sgr0) [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] $(tput setaf 3)?$(tput sgr0) " yn
    case $yn in
        [Yy]* ) cd $installDir/bin/gateway > /dev/null 2>&1 && ./start-gateway.sh > /dev/null 2>&1
                sleep 5
                echo "gateway=true" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                if (( $(ps -ef | grep -i $gt | grep -v grep | wc -l) > 0 )) ; then
                        echo "$(tput setaf 2)Selesai naikin service gateway$(tput sgr0)"
                        echo -e "$batas1"
                else
                        echo -e "--> $(tput setaf 1)Gatewaynyaa gak naek nih!!$(tput sgr0)"
                        echo -e "$batas1"
                fi
                break;;
        [Nn]* ) echo "gateway=false" >> $pathfile #Menyimpan hasil jawaban kedalam state .list-service.txt
                echo -e "$batas1"
                break;;
            * ) echo -e "Pilih [$(tput setaf 2)yY$(tput sgr0)||$(tput setaf 1)Nn$(tput sgr0)] !!!\n"
                echo -e "$batas1";;

    esac
done
}

#Function naikin automatis service yang ada di bin, dengan cara mengambil state yang ada di file .list-service.txt
naikinBinAuto () {
#Deklarasi variabel service
ch="conf/flume"
social="dolphin-social_lib"
lb="dolphin-lb_lib"
rpl="dolphin-replicate_lib"
sch="dolphin-sched_lib"
gt="dolphin-gateway_lib"
bc="dolphin-broadcast_lib"
cf="dolphin-learning_lib"
mt="dolphin-zoom_lib"

echo -e "$batas1"
echo -e "Mulai nyalain service yang ada di /bin/"
#Variabel untuk mencari value dari service di bawah ini di file state .list-service.txt
file=$(grep "coordinator" $pathfile | cut -d '=' -f 2)
if [ $file == true ]; then
        echo -e "$batas1"
        echo "--> $(tput setaf 3)Mulai jalanin service social...$(tput sgr0)"
        cd $installDir/bin/coordinator > /dev/null 2>&1 && ./start-social.sh > /dev/null 2>&1
        sleep 15
        if (( $( jcmd | grep -i 14000 | grep -v grep | wc -l) > 0 )) ; then
        posisi="/home/dolphin"
        py_status=$(find $posisi/ -maxdepth 1 -name "start_channel.py")
                if [ -z "$py_status" ]; then
                        echo "--> $(tput setaf 2)Selesai naikin service social$(tput sgr0)"
                        echo "import socket" >> ~/start_channel.py
                        echo "from os.path import exists" >> ~/start_channel.py
                        echo "import sys" >> ~/start_channel.py
                        echo "import re" >> ~/start_channel.py
                        echo "import struct" >> ~/start_channel.py
                        echo "" >> ~/start_channel.py
                        ip=$(hostname -I | awk '{print$1}')
                        echo ''local_ip = '"'"$ip"'"''' >> ~/start_channel.py
                        echo "" >> ~/start_channel.py
                        echo "if len(sys.argv) < 2:" >> ~/start_channel.py
                        echo "  print("'"'Please specify configuration file in $installDir/channel/conf/ !'"'");" >> ~/start_channel.py
                        echo "  exit()" >> ~/start_channel.py
                        echo ""  >> ~/start_channel.py
                        echo "file_path = "'"'"$installDir/channel/conf/"'"'" + sys.argv[1];"  >> ~/start_channel.py
                        echo "file_exists = exists(file_path)"  >> ~/start_channel.py
                        echo "if file_exists == False:"  >> ~/start_channel.py
                        echo '  print("The config file is not found")'  >> ~/start_channel.py
                        echo "  exit()"  >> ~/start_channel.py
                        echo ""  >> ~/start_channel.py
                        echo "result = re.search('flume-(.*).properties', sys.argv[1])" >> ~/start_channel.py
                        echo "config_name = result.group(1)" >> ~/start_channel.py
                        echo "" >> ~/start_channel.py
                        echo 'print("Starting channel with config : " + config_name)' >> ~/start_channel.py
                        echo "" >> ~/start_channel.py
                        echo "file = open(file_path, mode='r')">> ~/start_channel.py
                        echo "" >> ~/start_channel.py
                        echo "config_file = file.read()" >> ~/start_channel.py
                        echo "" >> ~/start_channel.py
                        echo 'command = "startup!###!:!###!" + config_name + "!###!:!###!" + config_file;' >> ~/start_channel.py
                        echo "" >> ~/start_channel.py
                        echo "command_size = len(command)" >> ~/start_channel.py
                        echo "" >> ~/start_channel.py
                        echo 'bytes_size = struct.pack(">H", command_size)' >> ~/start_channel.py
                        echo "bytes_command =  bytes(command)" >> ~/start_channel.py
                        echo "" >> ~/start_channel.py
                        echo "data = bytes_size + bytes_command;" >> ~/start_channel.py
                        echo "" >> ~/start_channel.py
                        echo "# Create a client socket" >> ~/start_channel.py
                        echo "clientSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM);" >> ~/start_channel.py
                        echo "# Connect to the server" >> ~/start_channel.py
                        echo "clientSocket.connect((local_ip,14000));" >> ~/start_channel.py
                        echo "# Send data to server" >> ~/start_channel.py
                        echo "clientSocket.send(data);" >> ~/start_channel.py
                        echo "" >> ~/start_channel.py
                        echo "clientSocket.close();" >> ~/start_channel.py
                        echo "" >> ~/start_channel.py
                fi
                echo -e "$batas1"
        else
                echo -e "--> $(tput setaf 1)Socialnya gak naek nih!!$(tput sgr0)"
                echo -e "$batas1"
        fi
fi

#Variabel untuk mencari value dari service di bawah ini di file state .list-service.txt
file=$(grep "replication" $pathfile | cut -d '=' -f 2)
if [ $file == true ]; then
        echo "--> $(tput setaf 3)Mulai jalanin service replication...$(tput sgr0)"
        cd $installDir/bin/replication > /dev/null 2>&1 && ./start-replication.sh > /dev/null 2>&1
        sleep 5
        if (( $(ps -ef | grep -i $rpl | grep -v grep | wc -l) > 0 )) ; then
        echo -e "--> $(tput setaf 2)Selesai naikin service replication$(tput sgr0)"
        echo -e "$batas1"
else
        echo -e "--> $(tput setaf 1)Replicationnyaa gak naek nih!!$(tput sgr0)"
        echo -e "$batas1"
fi
fi

#Variabel untuk mencari value dari service di bawah ini di file state .list-service.txt
file=$(grep "lb" $pathfile | cut -d '=' -f 2)
if [ $file == true ]; then
        echo "--> $(tput setaf 3)Mulai jalanin service lb...$(tput sgr0)"
        cd $installDir/bin/lb > /dev/null 2>&1 && ./start-lb.sh > /dev/null 2>&1
        sleep 5
        if (( $(ps -ef | grep -i $social | grep -v grep | wc -l) > 0 )) ; then
        echo -e "--> $(tput setaf 2)Selesai naikin service lb$(tput sgr0)"
        echo -e "$batas1"
else
        echo -e "--> $(tput setaf 1)Lbnyaa gak naek nih!!$(tput sgr0)"
        echo -e "$batas1"
        sleep 2
fi
fi

#Variabel untuk mencari value dari service di bawah ini di file state .list-service.txt
file=$(grep "broadcast" $pathfile | cut -d '=' -f 2)
if [ $file == true ]; then
        echo "--> $(tput setaf 3)Mulai jalanin service broadcast...$(tput sgr0)"
        cd $installDir/bin/broadcast > /dev/null 2>&1 && ./start-broadcast.sh > /dev/null 2>&1
        sleep 5
        if (( $(ps -ef | grep -i $bc | grep -v grep | wc -l) > 0 )) ; then
        echo -e "--> $(tput setaf 2)Selesai naikin service broadcast$(tput sgr0)"
        echo -e "$batas1"
else
        echo -e "--> $(tput setaf 1)Broadcastnyaa gak naek nih!!$(tput sgr0)"
        echo -e "$batas1"
        sleep 2
fi
fi

#Variabel untuk mencari value dari service di bawah ini di file state .list-service.txt
file=$(grep "learning" $pathfile | cut -d '=' -f 2)
if [ $file == true ]; then
        echo "--> $(tput setaf 3)Mulai jalanin service learning...$(tput sgr0)"
        cd $installDir/bin/classifier > /dev/null 2>&1 && ./start-learning.sh > /dev/null 2>&1
        sleep 5
        if (( $(ps -ef | grep -i $cf | grep -v grep | wc -l) > 0 )) ; then
        echo "--> $(tput setaf 2)Selesai naikin service learning$(tput sgr0)"
        echo -e "$batas1"
else
        echo -e "--> $(tput setaf 1)Learningnyaa gak naek nih!!$(tput sgr0)"
        echo -e "$batas1"
        sleep 2
fi
fi

#Variabel untuk mencari value dari service di bawah ini di file state .list-service.txt
file=$(grep "meeting" $pathfile | cut -d '=' -f 2)
if [ $file == true ]; then
        echo "--> $(tput setaf 3)Mulai jalanin service meeting...$(tput sgr0)"
        cd $instalDir/bin/meeting > /dev/null 2>&1 && ./start-meeting.sh > /dev/null 2>&1
        sleep 5
        if (( $(ps -ef | grep -i $mt | grep -v grep | wc -l) > 0 )) ; then
        echo "--> $(tput setaf 2)Selesai naikin service meeting$(tput sgr0)"
        echo -e "$batas1"
else
        echo -e "--> $(tput setaf 1)Meetingnyaa gak naek nih!!$(tput sgr0)"
        echo -e "$batas1"
        sleep 2
fi
fi

#Variabel untuk mencari value dari service di bawah ini di file state .list-service.txt
file=$(grep "scheduler" $pathfile | cut -d '=' -f 2)
if [ $file == true ]; then
        echo "--> $(tput setaf 3)Mulai jalanin service scheduler...$(tput sgr0)"
        cd $installDir/bin/scheduler > /dev/null 2>&1 && ./start-scheduler.sh > /dev/null 2>&1
        sleep 5
        if (( $(ps -ef | grep -i $sch | grep -v grep | wc -l) > 0 )) ; then
        echo "--> $(tput setaf 2)Selesai naikin service scheduler$(tput sgr0)"
        echo -e "$batas1"
else
        echo -e "--> $(tput setaf 1)Schedulernyaa gak naek nih!!$(tput sgr0)"
        echo -e "$batas1"
        sleep 2
fi
fi

#Variabel untuk mencari value dari service di bawah ini di file state .list-service.txt
file=$(grep "gateway" $pathfile | cut -d '=' -f 2)
if [ $file == true ]; then
        echo "--> $(tput setaf 3)Mulai jalanin service gateway...$(tput sgr0)"
        cd $installDir/bin/gateway > /dev/null 2>&1  && ./start-gateway.sh > /dev/null 2>&1
        sleep 5
        if (( $(ps -ef | grep -i $gt | grep -v grep | wc -l) > 0 )) ; then
        echo "$(tput setaf 2)Selesai naikin service gateway$(tput sgr0)"
        echo -e "$batas1"
        else
        echo -e "--> $(tput setaf 1)Gatewaynyaa gak naek nih!!$(tput sgr0)"
        echo -e "$batas1"
        sleep 2
fi
fi
}

#Kondisi jika file state .list-servic.txt di home/dolphin TIDAK ADA, maka eksekusi command dibawah kondisi ini
if [ -z $testList  ]; then
    #Memanggil function naikin UI manual
    naikinUImanual
    #Variabel untuk mencari state dari UI yang ada
    ui1=$(grep "1,$find1" $pathfile | cut -d '=' -f 2)
    ui2=$(grep "2,$find2" $pathfile | cut -d '=' -f 2)
    ui3=$(grep "3,$find3" $pathfile | cut -d '=' -f 2)
    #Mengecek dari variabel jika hanya terdapat 1 UI maka function CheckUIsatu di jalankan
    if [[ $ui1 == true ]] && [[ $ui2 == false || -z $ui2 ]] && [[ $ui3 == false || -z $ui3 ]]; then
        CheckUIsatu
    #Mengecek dari variabel jika hanya UI kedua yang mau dinyalain maka function CheckUIdua_log di jalankan
    elif [[ $ui1 == false || -z $ui1 ]] && [[ $ui2 == true ]] && [[ $ui3 == false || -z $ui3 ]]; then
        CheckUIdua_log
    #Mengecek dari variabel jika hanya UI ketiga yang mau dinyalain maka function CheckUItiga_log di jalankan
    elif [[ $ui1 == false || -z $ui1 ]] && [[ $ui2 == false || -z $ui2 ]] && [[ $ui3 == true ]]; then
        CheckUItiga_log
    #Mengecek dari variabel jika UI kesatu dan kedua yang mau dinyalain maka function CheckUIdua_log di jalanka                                                                                                                      n
    elif [[ $ui1 == true ]] && [[ $ui2 == true ]] && [[ $ui3 == false || -z $ui3 ]]; then
        CheckUIdua_log
    #Mengecek dari variabel jika ketiga UI dinyalakan maka function CheckUItiga_log di jalankan
    elif [[ $ui1 == true ]] && [[ $ui2 == true ]] && [[ $ui3 == true ]]; then
        CheckUItiga_log
    else
        sleep 0.1
    fi
#Kondisi jika file state .list-servic.txt di home/dolphin ADA, maka eksekusi command dibawah kondisi ini
else
    naikinUIauto
    #Mengecek dari variabel jika hanya terdapat 1 UI maka function CheckUIsatu di jalankan
    if [[ $ui1 == true ]] && [[ $ui2 == false || -z $ui2 ]] && [[ $ui3 == false || -z $ui3 ]]; then
        CheckUIsatu
    #Mengecek dari variabel jika hanya UI kedua yang mau dinyalain maka function CheckUIdua_log di jalankan
    elif [[ $ui1 == false || -z $ui1 ]] && [[ $ui2 == true ]] && [[ $ui3 == false || -z $ui3 ]]; then
        CheckUIdua_log
    #Mengecek dari variabel jika hanya UI ketiga yang mau dinyalain maka function CheckUItiga_log di jalankan
    elif [[ $ui1 == false || -z $ui1 ]] && [[ $ui2 == false || -z $ui2 ]] && [[ $ui3 == true ]]; then
        CheckUItiga_log
    #Mengecek dari variabel jika UI kesatu dan kedua yang mau dinyalain maka function CheckUIdua_log di jalanka                                                                                                                      n
    elif [[ $ui1 == true ]] && [[ $ui2 == true ]] && [[ $ui3 == false || -z $ui3 ]]; then
        CheckUIdua_log
    #Mengecek dari variabel jika ketiga UI dinyalakan maka function CheckUItiga_log di jalankan
    elif [[ $ui1 == true ]] && [[ $ui2 == true ]] && [[ $ui3 == true ]]; then
        CheckUItiga_log
    else
        sleep 0.1
    fi
fi

while true; do
echo "$batas2"
echo "$batas1"
echo "Mau jalanin service di bin niihh!!"
echo "Kalau UI udh jalan pilih [$(tput setaf 2)yY$(tput sgr0)] aja yak!!"
read -p "kalau belum tunggu dulu aja yak? " yY
echo -e "$batas1"
echo "$batas2"
case $yY in
        [Yy]* ) break;;
        * ) echo "Pilih [$(tput setaf 2)yY$(tput sgr0)]!!!!";;
    esac
done

#Kondisi jika file state .list-servic.txt di home/dolphin TIDAK ADA, maka eksekusi command dibawah kondisi ini
if [ -z $testList  ]; then
    naikinBinManual
#Kondisi jika file state .list-servic.txt di home/dolphin ADA, maka eksekusi command dibawah kondisi ini
else
    naikinBinAuto
fi
echo -e "Patching udah selesai & service + channel udah running"
echo -e "$batas1"

#Text yang akan dikirimkan ke notifikasi channel telegram notification patching
textL="=================================="
textL="$textL%0APatching Done"
textL="$textL%0AAll service + channel udah UP!"
textL="$textL%0ASangkyuh $selected_choice_person 🙏🏻 !!"
textL="$textL%0A=================================="

#Curl mengirimkan notifikasi ke channel telegram notification patching
curl -s -d parse_mode=HTML -d chat_id="$chat_id" -d text="$textL" https://api.telegram.org/bot$token/sendMessage > /dev/null 2>&1

cmd=$1

wait_for_http_ok() {
 while true
  do
    curl --silent -Lk -o /dev/null --connect-timeout 5 "$1"
    ret=$?
    if [[ $ret -eq 0 ]]
    then
       break
    fi
 done
}
file=$(grep "coordinator" $pathfile | cut -d '=' -f 2)
if [ $file == true ]; then
        channel_count=$(cat /home/dolphin/.list-channel.txt | wc -l)
        counter=1
        until [ "$counter" -gt "$channel_count" ]
        do
                channel_conf=$(sed -n $counter'p' /home/dolphin/.list-channel.txt)
                channel_id=$(sed -n $counter'p' $posisi/.list-channel.txt | cut -d '-' -f 2)
                channel_port=$(sed -n $counter'p' /home/dolphin/.list-channel.txt | cut -d '.' -f 4 | cut -d '-' -f 2)
                echo "$batas2"
                echo "$batas1"
                echo "Starting Channel $counter"
                echo "/usr/bin/python $posisi/start_channel.py "$channel_conf""
                /usr/bin/python $posisi/start_channel.py "$channel_conf" > /dev/null 2>&1
                wait_for_http_ok "http://localhost:$channel_port/actuator/prometheus"
                echo "channel $counter $channel_id started"
                echo "$batas1"
                ((counter++))
        done
                echo "all channel started"
else
        sleep 0.1
fi
trap 2
