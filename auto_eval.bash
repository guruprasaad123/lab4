#!/bin/bash
############################################################################################################################
# COMMON LIB
############################################################################################################################
function ae_echo_ ()
{
    echo $* | tee -a ${LOGFILE}
}
############################################################################################################################
function read_an_answer_ ()
{
    read_an_answer_n="$1";
    shift
    read_an_answer_s=`echo -n "Type your choice ( "
    for read_an_answer_c in $* ;
    do
       echo -n \$read_an_answer_c" ";
    done
    echo  -n ") : "`
    read_an_answer_continue=1;
    while [ $read_an_answer_continue -eq 1 ]
    do
        ae_echo_ -n $read_an_answer_s
        read read_an_answer_v; 
        if [ $LOGYN -eq 1 ]
        then
            echo $read_an_answer_v >> ${LOGFILE}
        fi
        for read_an_answer_c in $* ;
        do
            if [ "$read_an_answer_c" = "$read_an_answer_v" ]
            then
                read_an_answer_continue=0;
                break;
            fi
        done
        if [ $read_an_answer_continue -eq 1 ]
        then
            ae_echo_ "Wrong answer "$read_an_answer_v
        fi
    done
    eval $read_an_answer_n=$read_an_answer_v;
    ae_echo_ -e "\n"
}
############################################################################################################################
function msg_ ()
{

cat << msg_EOFi | tee -a ${LOGFILE}

===============================================================================
msg_EOFi

case $1 in
    1)
    cat << msg_EOF1 | tee -a ${LOGFILE} ;;
Warning : $2
If from message above you have a solution, fix problems in an other terminal.
And afterward chose again to do an archive in the menu
msg_EOF1
    2)
    cat << msg_EOF2 | tee -a ${LOGFILE} ;;
Error : $2
If from message above you have a solution, fix problems in an other terminal.
And afterward choose again to do an archive in the menu
msg_EOF2
    3)
    cat << msg_EOF3 | tee -a ${LOGFILE} ;;
Error :  $2
Try to fix problem or contact teachers.
msg_EOF3
    4)
    cat << msg_EOF4 | tee -a ${LOGFILE} ;;
$2
msg_EOF4
    5)
    cat << msg_EOF5 | tee -a ${LOGFILE} ;;
$2
$3
msg_EOF5
    6)
    cat << msg_EOF6 | tee -a ${LOGFILE} ;;
$2
$3
$4
msg_EOF6
    7)
    cat << msg_EOF7 | tee -a ${LOGFILE} ;;
Warning : $2
msg_EOF7
    8)
    cat << msg_EOF8 | tee -a ${LOGFILE} ;;
Error : $2
msg_EOF8
    esac

cat << msg_EOFi | tee -a ${LOGFILE}
===============================================================================

msg_EOFi
}
############################################################################################################################
function nb_ligne_ ()
{
        eval $1=`cat $2 | wc -l | cut -d' ' -f1`
}
############################################################################################################################
function clean_tmpdir_ ()
{
if [ -d $TMPDIR ]
then
    rm -rf $TMPDIR
fi
}
############################################################################################################################
function clean_autodir_ ()
{
if [ -d $AUTODIR ]
then
    msg_ 7 "Cleaning"
    cat<<clean_autodir_EOF1 | tee -a ${LOGFILE}
Do you want to clean (c) or save (s) temporary folder $AUTODIR ?
This folder may contain compilation, execution and evaluation of last evaluated archive.
If you save it, it's your responsability to do the cleaning

clean_autodir_EOF1
    read_an_answer_ clean_autodir_A c s
    if [ "$clean_autodir_A" = c ]
    then
        rm -rf $AUTODIR
    fi
fi
}
############################################################################################################################
function eval_arch_check_ ()
{
if [ -z "$EVALARCH" ]
then
    EVALARCH="${TARFILE}_${GROUP_ID}.tar.gz"
    msg_ 6 "Name of archive must be $EVALARCH" "If it's not the case change it in an other terminal" \
           "And afterward choose again to evaluate an archive in the menu"
fi
eval_arch_check_EVALARCH=`basename $EVALARCH`;
msg_ 4 "Checking archive $eval_arch_check_EVALARCH "
ae_echo_ "Looking for archive"
if [ -f $EVALARCH -a -s $EVALARCH ]
then
    ae_echo_ "Archive found and is a non null regular file"
    gzip -t $EVALARCH >& /dev/null
    if [ $? -eq 0 ]
    then
        ae_echo_ "Archive is in gz compressed format"
        tar tzf $EVALARCH >& /dev/null
        if [ $? -eq 0 ]
        then
            ae_echo_ "Archive is in tar format"
            ae_echo_ "Archive is present and in correct format";
            return 0
        else
            msg_ 8 "File $eval_arch_check_EVALARCH is not in correct tar format";
        fi
    else
        msg_ 8 "File $eval_arch_check_EVALARCH is not in gz compressed format";
    fi
else
    msg_ 8 "File $eval_arch_check_EVALARCH is missing or a null regular file";
fi
return 1
}
############################################################################################################################
function eval_arch_genrep_ ()
{
msg_ 4 "Generate folder"
if [ -d $AUTODIR ]
then
    rm -rf $AUTODIR
fi
mkdir $AUTODIR
if [ $? -eq 0 ]
then
    ae_echo_ "$AUTODIR directory created."
    cd $AUTODIR
    return 0
else
    ae_echo_ "Impossible to create $AUTODIR directory"
    return 1
fi
}
############################################################################################################################
function eval_arch_unpack_ ()
{
msg_ 4 "Unpacking archive $EVALARCH"
if [ -f .unpack_ok ]
then
    rm .unpack_ok
    rm -f .nb_compil
    rm -f .nb_compil_scale
    rm -f .nb_run
    rm -f .nb_run_scale
fi
tar xzf $CURDIR/$EVALARCH
if [ $? -eq 0 ]
then
    ae_echo_ "Archive correctly extracted"
    if [ -s ${TMPDIR}/fts ]
    then
        msg_ 4 "Adding teacher's file"
        for eval_arch_unpack_f in `cat ${TMPDIR}/fts`
        do
            if [ -s ${TMPDIR}/$eval_arch_unpack_f ]
            then
                cp -f ${TMPDIR}/$eval_arch_unpack_f .
                ae_echo_ "Adding $eval_arch_unpack_f"
            else
                msg_ 3 "Teacher file ${TMPDIR}/$eval_arch_unpack_f not here or null ???"
                return 1
            fi
        done
        touch .unpack_ok
        return 0
    fi
else
    msg_ 8 "Impossible to unpack archive"
    return 1
fi
}
############################################################################################################################
function eval_arch_compil_ ()
{
eval_arch_compil_DO=1;
if [ -f .nb_compil ]
then
    eval_arch_compil_COK=`ls *.cc *.h .nb_compil -rtla 2>/dev/null | sed -n '$p' | grep -c ".nb_compil"`
    if [ $eval_arch_compil_COK -eq 1 ]
    then
        eval_arch_compil_NC=`cat .nb_compil`
        if [ $eval_arch_compil_NC -eq $NBEXE ]
        then
            eval_arch_compil_DO=0;
        else
            rm .nb_compil
            rm .nb_compil_scale
        fi
    else
        rm .nb_compil
        rm .nb_compil_scale
    fi
fi
if [ $eval_arch_compil_DO -eq 1 ]
then
    if [ -f .unpack_ok ]
    then
        msg_ 4 "Compile archive $EVALARCH"

        eval_arch_compil_K=0;
        eval_arch_compil_KT=0;
        eval_arch_compil_KS=0;
        for ((eval_arch_compil_i=1;eval_arch_compil_i<=NBEXE;++eval_arch_compil_i))
        do
            eval_arch_compil_EXE='';
            eval_arch_compil_F=`sed -n $eval_arch_compil_i'p' $TMPDIR/list_of_ex`
            eval_arch_compil_F1=`echo $eval_arch_compil_F | cut -f1 -d' '`;
            eval_arch_compil_NOPOINT=`echo $eval_arch_compil_F | grep -c '###'`;
            eval_arch_compil_SCALE=`sed -n $eval_arch_compil_i'p' $TMPDIR/list_of_ex_coef`
            eval_arch_compil_W=`echo $eval_arch_compil_F| wc -w`
            if [ $eval_arch_compil_W -gt 1 ]
            then
                if [ -f list_o_$$ ]
                then
                    rm list_o_$$;
                fi
                for eval_arch_compil_C in `echo $eval_arch_compil_F`
                do
                    if [ -f ${eval_arch_compil_C}*.cc ]
                    then
                        if [ -f ${eval_arch_compil_C}.o ]
                        then
                            rm ${eval_arch_compil_C}.o
                        fi
                        g++ -std=c++98 -pedantic-errors ${eval_arch_compil_C}.cc -c -o ${eval_arch_compil_C}.o >& /dev/null;
                        if [ $? -ne 0 ]
                        then
                            ae_echo_ "Problem : ${eval_arch_compil_C}.cc didn't compile correctly"
                        else
                            ae_echo_ "${eval_arch_compil_C}.cc compile correctly"
                        fi
                        echo "${eval_arch_compil_C}.o" >> list_o_$$
                    fi
                done
                if [ -s list_o_$$ ]
                then
                    eval_arch_compil_EXE=`cat list_o_$$`;
                    rm list_o_$$;
                fi
            else
                if [ -f ${eval_arch_compil_F}.cc ]
                then
                    eval_arch_compil_EXE=${eval_arch_compil_F}.cc;
                fi
            fi
            if [ -x $eval_arch_compil_F1 ]
            then
                rm $eval_arch_compil_F1
            fi
            if [ `echo $eval_arch_compil_EXE|wc -w` -gt 0 ]
            then
                g++ -std=c++98 -pedantic-errors $eval_arch_compil_EXE -o $eval_arch_compil_F1 >& /dev/null;
                if [ $? -eq 0 ]
                then
                    ae_echo_ "Program ${eval_arch_compil_F1} compile correctly"
                    if [ $eval_arch_compil_NOPOINT -lt 1 ]
                    then
                        echo $((eval_arch_compil_K++))>>/dev/null;
                        echo $((eval_arch_compil_KS=eval_arch_compil_KS+eval_arch_compil_SCALE))>>/dev/null;
                    fi
                    echo $((eval_arch_compil_KT++))>>/dev/null;
                else
                    ae_echo_ "Problem : program ${eval_arch_compil_F1} didn't compile correctly"
                fi
                ls ${eval_arch_compil_F1}_*.res >& /dev/null
                if [ $? -eq 0 ]
                then
                    rm ./${eval_arch_compil_F1}_*.res
                fi
            fi
        done
        if [ $eval_arch_compil_K -gt 0 ]
        then
            echo $eval_arch_compil_KS > .nb_compil_scale
        fi
        if [ $eval_arch_compil_KT -gt 0 ]
        then
            echo $eval_arch_compil_KT > .nb_compil
        fi
        return 0
    else
        msg_ 8 "No unpacked archive !! Compilation of $EVALARCH not possible"
        return 1
    fi
fi
}
############################################################################################################################
function eval_arch_run_ ()
{
eval_arch_run_DO=1;
if [ -f .nb_run ]
then
    eval_arch_run_EXELIST=`cat $TMPDIR/list_of_ex | cut -f1 -d' '`
    eval_arch_run_ROK=`ls $eval_arch_run_EXELIST .nb_run -rtla 2>/dev/null | sed -n '$p' | grep -c ".nb_run"`
    if [ $eval_arch_run_ROK -eq 1 ]
    then
        eval_arch_run_NR=`cat .nb_run`
        if [ $eval_arch_run_NR -eq $NBEXE ]
        then
            eval_arch_run_DO=0;
        else
            rm .nb_run
            rm .nb_run_scale
        fi
    else
        rm .nb_run
        rm .nb_run_scale
    fi
fi
if [ $eval_arch_run_DO -eq 1 ]
then
    if [ -f .nb_compil ]
    then
        msg_ 4 "Run archive $EVALARCH"

        eval_arch_run_K=0;
        eval_arch_run_KT=0;
        eval_arch_run_KS=0;
        for ((eval_arch_run_i=1;eval_arch_run_i<=NBEXE;++eval_arch_run_i))
        do
            eval_arch_run_EXE='';
            eval_arch_run_F1=`sed -n $eval_arch_run_i'p' $TMPDIR/list_of_ex | cut -f1 -d' '`
            eval_arch_run_NOPOINT=`sed -n $eval_arch_run_i'p' $TMPDIR/list_of_ex | grep -c '###'`;
            eval_arch_run_SCALE=`sed -n $eval_arch_run_i'p' $TMPDIR/list_of_ex_coef`
            eval_arch_run_L=0;
            eval_arch_run_M=0;
            if [ -x $eval_arch_run_F1 ]
            then
                ls $eval_arch_run_F1*.dat >& /dev/null
                if [ $? -ne 0 ]
                then
                    msg_ 3 "Configuration problem. No data file for $eval_arch_run_F1. Rebuilt "
                    return 1
                fi
                for eval_arch_run_DATA in `ls $eval_arch_run_F1*.dat`
                do
                    echo $((eval_arch_run_M++))>>/dev/null;
                    eval_arch_run_RES=`basename $eval_arch_run_DATA .dat`.res
                    { ./$eval_arch_run_F1 < $eval_arch_run_DATA  &> $eval_arch_run_RES; } 2> tmp_$$ 
                    if [ $? -eq 0 ]
                    then
                        ae_echo_ "Program ${eval_arch_run_F1} run correctly with $eval_arch_run_DATA"
                        echo $((eval_arch_run_L++))>>/dev/null;
                        rm tmp_$$
                    else
                        ae_echo_ "Problem : program ${eval_arch_run_F1} didn't run correctly with $eval_arch_run_DATA"
                        ae_echo_ "Error message is :"
                        cat tmp_$$ |sed 's/\.\/$eval_arch_run_F1 < $eval_arch_run_DATA &>$eval_arch_run_RES//' |\
                                    sed "s/$MYNAMESED: line [0-9][0-9][0-9]://"| tee -a ${LOGFILE}
                        rm tmp_$$
                   #     break;
                    fi
                done
                if [ $eval_arch_run_L  -eq $eval_arch_run_M ]
                then
                    if [ $eval_arch_run_NOPOINT -lt 1 ]
                    then
                        echo $((eval_arch_run_K++))>>/dev/null;
                        echo $((eval_arch_run_KS=eval_arch_run_KS+eval_arch_run_SCALE))>>/dev/null;
                    fi
                    echo $((eval_arch_run_KT++))>>/dev/null;
                fi
            fi
        done
        if [ $eval_arch_run_K -gt 0 ]
        then
            echo $eval_arch_run_KS > .nb_run_scale
        fi
        if [ $eval_arch_run_KT -gt 0 ]
        then
            echo $eval_arch_run_KT > .nb_run
        fi
        return 0
    else
        msg_ 8 "No full or partial compilation !! Running $EVALARCH not possible"
        return 1
    fi
fi
}
############################################################################################################################
function eval_arch_diff_ ()
{
if [ -f .nb_run ]
then
    eval_arch_diff_DO=1;
    if [ -f .nb_diff ]
    then
        eval_arch_diff_DOK=`ls *.res .nb_diff -rtla | sed -n '$p' | grep -c ".nb_diff"`
        if [ $eval_arch_diff_DOK -eq 1 ]
        then
            nb_ligne_ eval_arch_diff_ND .nb_diff
            if [ $eval_arch_diff_ND -eq 0 ]
            then
                eval_arch_diff_DO=0;
            else
                rm .nb_diff
            fi
        else
            rm .nb_diff
        fi
    fi
    if [ $eval_arch_diff_DO -eq 1 ]
    then
        msg_ 4 "Evaluate result of archive $EVALARCH"
        rm .nb_point >& /dev/null
        touch .nb_diff
        for ((eval_arch_diff_i=1;eval_arch_diff_i<=NBEXE;++eval_arch_diff_i))
        do
            eval_arch_diff_K=0;
            eval_arch_diff_L=0;
            eval_arch_diff_EXE='';
            eval_arch_diff_F1=`sed -n $eval_arch_diff_i'p' $TMPDIR/list_of_ex | cut -f1 -d' '`
            eval_arch_diff_NOPOINT=`sed -n $eval_arch_diff_i'p' $TMPDIR/list_of_ex | grep -c '###'`;
            eval_arch_diff_SCALE=`sed -n $eval_arch_diff_i'p' $TMPDIR/list_of_ex_coef`
            eval_arch_diff_NBPOINT_EXO=0;
            eval_arch_diff_NBPOINT_TOTAL=0;
            if [ -s $eval_arch_diff_F1.reg ]
            then
                nb_ligne_ eval_arch_diff_NBREG ${eval_arch_diff_F1}.reg
                for ((eval_arch_diff_j=1;eval_arch_diff_j<=eval_arch_diff_NBREG;++eval_arch_diff_j))
                do
                    eval_arch_diff_VP=`sed -n $eval_arch_diff_j'p' ${eval_arch_diff_F1}.reg | cut -d':' -f3`
                    eval_arch_diff_NBPOINT_TOTAL=`echo "scale=8; $eval_arch_diff_NBPOINT_TOTAL+$eval_arch_diff_VP" | bc -l `
                done
                for eval_arch_diff_DAT in `ls $eval_arch_diff_F1*.dat`
                do
                    echo $((eval_arch_diff_L++))>>/dev/null;
                    eval_arch_diff_M=0;
                    eval_arch_diff_NBPOINT_DAT=0;
                    eval_arch_diff_DATN=`basename $eval_arch_diff_DAT .dat|awk 'BEGIN{FS="_";}{print $NF}'`
                    eval_arch_diff_SOL=`basename $eval_arch_diff_DAT .dat`.sol
                    eval_arch_diff_RES=`basename $eval_arch_diff_DAT .dat`.res
                    if [ ! -s $eval_arch_diff_SOL ]
                    then
                        msg_ 3 "Configuration problem ! $eval_arch_diff_DAT present but not $eval_arch_diff_SOL"
                        break;
                    fi
                    if [ -s $eval_arch_diff_RES ]
                    then
                        for ((eval_arch_diff_j=1;eval_arch_diff_j<=eval_arch_diff_NBREG;++eval_arch_diff_j))
                        do
                            eval_arch_diff_VARN=`sed -n $eval_arch_diff_j'p' ${eval_arch_diff_F1}.reg | cut -d':' -f1`;
                            eval_arch_diff_REG="^[ ]*${eval_arch_diff_VARN}[ ]*:[ ]*"
                            eval_arch_diff_VT=`sed -n $eval_arch_diff_j'p' ${eval_arch_diff_F1}.reg | cut -d':' -f2`
                            eval_arch_diff_VP=`sed -n $eval_arch_diff_j'p' ${eval_arch_diff_F1}.reg | cut -d':' -f3`
                            eval_arch_diff_VC=`basename $eval_arch_diff_DAT .dat`_${eval_arch_diff_j}_COMP
                            eval_arch_diff_VS=`basename $eval_arch_diff_DAT .dat`_${eval_arch_diff_j}_SOL
                            if [ "$eval_arch_diff_VT" = "R" ]
                            then
                                sed -n $eval_arch_diff_j'p' ${eval_arch_diff_SOL} |  awk '{print $1*1.}' > $eval_arch_diff_VS
                            elif [ "$eval_arch_diff_VT" = "T" ]
                            then
                                sed -n $eval_arch_diff_j'p' ${eval_arch_diff_SOL} > $eval_arch_diff_VS
                            elif [ "$eval_arch_diff_VT" = "C" ]
                            then
                                sed -n $eval_arch_diff_j'p' ${eval_arch_diff_SOL} |  awk '{print $1*1.,$2*1.}' > $eval_arch_diff_VS
                            elif [ "$eval_arch_diff_VT" = "E" ]
                            then
                                sed -n $eval_arch_diff_j'p' ${eval_arch_diff_SOL} |  awk '{printf("%.15f %d\n", $1*1.,$2);}' > $eval_arch_diff_VS
                            else
                                msg_ 3 "Configuration problem. Some regular expretion in ${eval_arch_diff_F1}.reg  are of unknow type : $eval_arch_diff_VT"
                                return 1
                            fi
                            eval_arch_diff_GREP=`grep "$eval_arch_diff_REG" $eval_arch_diff_RES` 
                            if [ $? -eq 0 ]
                            then
                                eval_arch_diff_GREP_count=`grep -c "$eval_arch_diff_REG" $eval_arch_diff_RES`
                            else
                                eval_arch_diff_GREP_count=0
                            fi
                            if [ $eval_arch_diff_GREP_count -eq 1 ]
                            then
                                if [ "$eval_arch_diff_VT" = "R" ]
                                then
                                    echo $eval_arch_diff_GREP | awk -v e=$EPSILON_RES 'BEGIN{ FS=":";}{if ($2*1.<e && $2*1.>-e) print 0.; else print $2*1.;}' > $eval_arch_diff_VC
                                elif [ "$eval_arch_diff_VT" = "T" ]
                                then
                                    echo $eval_arch_diff_GREP | cut -d':' -f2- > $eval_arch_diff_VC
                                elif [ "$eval_arch_diff_VT" = "C" ]
                                then
                                    echo $eval_arch_diff_GREP | cut -d':' -f2- | sed 's/(//
                                                                                      s/)//
                                                                                      s/i//' | awk -v e=$EPSILON_RES 'BEGIN{ FS=",";}{if ($1*1.<e && $1*1.>-e ) r=0.; else r=$1*1.;if ($2*1.<e && $2*1.>-e ) i=0.; else i=$2*1.; print r,i}' > $eval_arch_diff_VC
#s/i//' | awk -v e=$EPSILON_RES 'BEGIN{ FS=",";e=1.e-10;}{if ($1*1.<e && $1*1.>-e ) r=0.; else r=$1*1.;if ($2*1.<e && $2*1.>-e ) i=0.; else i=$2*1.; print r,i}' > $eval_arch_diff_VC
                                elif [ "$eval_arch_diff_VT" = "E" ]
                                then
                                    echo $eval_arch_diff_GREP | cut -d':' -f2- | sed 's/E/ /' | awk '{printf("%.15f %d\n", $1*1.,$2);}' > $eval_arch_diff_VC
                                fi
                                if [ "$eval_arch_diff_VT" = "E" ]
                                then
                                    paste $eval_arch_diff_VC $eval_arch_diff_VS | awk -v e=$EPSILON_RES 'BEGIN{m=0.;p=0;d=0;m1=0.;m2=0.;e1=0;e2=0;}{
                                         d=$2-$4;
                                         m1=$1;m2=$3;
                                         e1=$2;e2=$4;
                                         if (d==1 || d==-1)
                                         {
                                             if (d>0)
                                             {
                                                 m2=m2/10.;
                                                 e2=e2+1;
                                             }
                                             else
                                             {
                                                 m1=m1/10.;
                                                 e1=e1+1;
                                             }
                                         }
                                         if (m2<e && m2>-e)
                                         {
                                             m=m1;
                                         }
                                         else
                                         {
                                             m=(m1-m2)/m2;
                                         }
                                         if (e2<e && e2>-e)
                                         {
                                             p=e1;
                                         }
                                         else
                                         {
                                             p=(e1-e2)/e2;
                                         }
                                     }END{if (m<e && m>-e && p<e && p>-e) print 1; else print 0;}' | grep -q '1';
                                else
                                     diff -b -w -a -q $eval_arch_diff_VC $eval_arch_diff_VS >> /dev/null
                                fi
                                if [ $? -ne 0 ]
                                then
                                    echo "$eval_arch_diff_VC $eval_arch_diff_VS : $eval_arch_diff_F1 $eval_arch_diff_DATN ${eval_arch_diff_VARN}" >> .nb_diff
                                    ae_echo_ "For $eval_arch_diff_DAT input parameter setting, program '$eval_arch_diff_F1' don't give correct result for ${eval_arch_diff_VARN} result."

                                else
                                    echo $((eval_arch_diff_M++))>>/dev/null;
                                    eval_arch_diff_NBPOINT_DAT=`echo "scale=8; ${eval_arch_diff_NBPOINT_DAT}+${eval_arch_diff_VP}" | bc -l `
                                fi
                            else
                                echo '' >$eval_arch_diff_VC
                                echo "$eval_arch_diff_VC $eval_arch_diff_VS : $eval_arch_diff_F1 $eval_arch_diff_DATN ${eval_arch_diff_VARN}" >> .nb_diff
                                ae_echo_ "For $eval_arch_diff_DAT input parameter setting, program '$eval_arch_diff_F1'  result ${eval_arch_diff_VARN} was not found."
                            fi
                        done
                        echo $((eval_arch_diff_K += $eval_arch_diff_M))>>/dev/null;
                        eval_arch_diff_NBPOINT_EXO=`echo "scale=8; ${eval_arch_diff_NBPOINT_DAT}+${eval_arch_diff_NBPOINT_EXO}" | bc -l `
                    else
                        ae_echo_ "For $eval_arch_diff_DAT input parameter setting, program '$eval_arch_diff_F1'  results where not found."
                    fi
                done
                if [ $eval_arch_diff_K -gt 0 ]
                then
                    eval_arch_diff_MRI=`echo "scale=0; $eval_arch_diff_K/$eval_arch_diff_L" | bc -l `
                    eval_arch_diff_MR=`echo "scale=2; $eval_arch_diff_K/$eval_arch_diff_L" | bc -l `
                    if [ $eval_arch_diff_NOPOINT -lt 1 ]
                    then
                        eval_arch_diff_NBPOINT_EXO_moy=`echo "scale=8; $eval_arch_diff_SCALE*$eval_arch_diff_NBPOINT_EXO/$eval_arch_diff_L" | bc -l `
                    else
                        eval_arch_diff_NBPOINT_EXO_moy=`echo "scale=8; $eval_arch_diff_SCALE*$eval_arch_diff_NBPOINT_EXO*6./($eval_arch_diff_L*4.)" | bc -l `
                    fi
                    echo "$eval_arch_diff_F1 $eval_arch_diff_NBPOINT_EXO_moy $eval_arch_diff_NBPOINT_TOTAL $eval_arch_diff_MR $eval_arch_diff_NBREG" >> .nb_point
                    ae_echo_ "=> For input parameter setting, program '$eval_arch_diff_F1' give $eval_arch_diff_MRI out of $eval_arch_diff_NBREG correct result(s)."
                else
                    ae_echo_ "=> For input parameter setting, program '$eval_arch_diff_F1' doesn't give  any correct result from $eval_arch_diff_NBREG expected."
                    echo "$eval_arch_diff_F1 0. $eval_arch_diff_NBPOINT_TOTAL 0. $eval_arch_diff_NBREG" >> .nb_point
                fi
            else
                ae_echo_ "$eval_arch_diff_F1 is not evaluated by $MYNAME. Check lab subject. If from subject it should you've got a configuration problem. Try to rebuild $MYNAME or contact teachers"
            fi
        done
        return 0
    fi
else
    msg_ 8 "No full or partial run !! Analyzing results is not possible"
    return 1
fi
}
############################################################################################################################
function disp_diff_arch_ ()
{
if [ -s .nb_diff ]
then
        msg_ 4 "Display difference from last evaluation of archive $EVALARCH"
        nb_ligne_ disp_diff_arch_ND .nb_diff
        for ((disp_diff_arch_i=1;disp_diff_arch_i<=$disp_diff_arch_ND;++disp_diff_arch_i))
        do
            disp_diff_arch_D=`sed -n $disp_diff_arch_i'p' .nb_diff`
            disp_diff_arch_VC=`echo $disp_diff_arch_D | cut -d' ' -f 1`
            disp_diff_arch_VS=`echo $disp_diff_arch_D | cut -d' ' -f 2`
            ae_echo_ `echo $disp_diff_arch_D| cut -d':' -f 2`" :"
            diff -b -w -a --old-line-format='yours    > '%L --new-line-format='solution > '%L $disp_diff_arch_VC $disp_diff_arch_VS |tee -a ${LOGFILE}
        done
fi
}
############################################################################################################################
# STUDENT LIB
############################################################################################################################
function first_choice_ ()
{
cat<<first_choice_EOF1 | tee -a ${LOGFILE}

////////////////////////////////////////////////////////
///   This is auto_eval version $VERSION for LAB $LABN $YEAR
////////////////////////////////////////////////////////
/// Current status
first_choice_EOF1

if [ -z "$EVALARCH" ]
then
    first_choice_EVALARCH="${TARFILE}_${GROUP_ID}.tar.gz"
else
    first_choice_EVALARCH="$EVALARCH"
fi
if [ -s ${CURDIR}/$first_choice_EVALARCH ]
then
    ae_echo_ "///  Archive file $first_choice_EVALARCH present"
    if [ -d $AUTODIR ]
    then
        ls -1 $AUTODIR/.unpack_ok >& /dev/null && ae_echo_ "///  Archive unpacked successfully"
        ls -1 $AUTODIR/.nb_compil >& /dev/null && ae_echo_ "///  "`cat $AUTODIR/.nb_compil`" out of $NBEXE programs compile successfully"
        ls -1 $AUTODIR/.nb_run >& /dev/null && ae_echo_ "///  "`cat $AUTODIR/.nb_run`" out of $NBEXE programs run successfully"
        ls -1 $AUTODIR/.nb_point >& /dev/null && ae_echo_ "///  "`cat $AUTODIR/.nb_point | awk 'BEGIN{c=0;s=0}{c+=$4;s+=$5;}END{printf("%.1f out of %.0f correct results where obtain",c,s);}'`
    fi
    if [ -d $AUTODIR -a -s ${AUTODIR}/.nb_diff ]
    then
        cat<<first_choice_EOF2 | tee -a ${LOGFILE}
////////////////////////////////////////////////////////

What do you want to do ?

    a) prepare an archive of your work.
    b) evaluate archive already generated.
    c) display differences from solution of last evaluated archive
    q) stop using this program

first_choice_EOF2
        read_an_answer_ first_choice_C a b c q;
    else
        cat<<first_choice_EOF3 | tee -a ${LOGFILE}
////////////////////////////////////////////////////////

What do you want to do ?

    a) prepare an archive of your work.
    b) evaluate archive already generated.
    q) stop using this program

first_choice_EOF3
        read_an_answer_ first_choice_C a b q;
    fi
else
    cat<<first_choice_EOF3 | tee -a ${LOGFILE}
///   No archive file $first_choice_EVALARCH present
////////////////////////////////////////////////////

What do you want to do ?

    a) prepare an archive of your work.
    q) stop using this program

first_choice_EOF3
    read_an_answer_ first_choice_C a q;
fi
}
############################################################################################################################
function choose_group_ ()
{
if [ -s $TMPDIR/gn ]
then
    eval $1=`cat $TMPDIR/gn`
else
    msg_ 4 "Setting your lab group"
    ae_echo_ "Please what is your group letter ?"
    read_an_answer_ choose_group_GL A B C D;
    ae_echo_ "Please what is your group number ?"
    read_an_answer_ choose_group_GN 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20;
    choose_group_GLN=`echo "${choose_group_GL}_${choose_group_GN}"`
    echo "$choose_group_GLN" > $TMPDIR/gn
    eval $1=$choose_group_GLN
fi
}
############################################################################################################################
function prb_arch_ ()
{
cat << prb_arch_EOF1 | tee -a ${LOGFILE}
===============================================================================
File $2 won't be archived
Sorry, $3 !
prb_arch_EOF1
if [ $# -gt 3 ]
then
cat << prb_arch_EOF2 | tee -a ${LOGFILE}
$4
===============================================================================
prb_arch_EOF2
fi
echo $(($1++))>>/dev/null;
}
############################################################################################################################
function gen_arch_ ()
{
gen_arch_TARFILE="${TARFILE}_${GROUP_ID}.tar"
if [ -s $gen_arch_TARFILE ]
then
    rm -f ./$gen_arch_TARFILE
fi
if [ -s ${gen_arch_TARFILE}.gz ]
then
    rm -f ./${gen_arch_TARFILE}.gz
fi
msg_ 4 "Archiving file for lab $LABN"
gen_arch_K=0
for gen_arch_f in `cat ${TMPDIR}/ffn`
do
    if [ -s ${gen_arch_f} -a -f ${gen_arch_f} -a -r ${gen_arch_f} ]
    then
        if [ -x ${gen_arch_f} ]
        then
            prb_arch_ gen_arch_K ${gen_arch_f} " your file is present, but it is an executable file" "Do a 'chmod 644 ${gen_arch_f}'"
        else
            tar rhf $gen_arch_TARFILE ./${gen_arch_f}
            if [ $? -eq 0 ]
            then
                ae_echo_ "File '${gen_arch_f}' correctly archived"
            else
                prb_arch_ gen_arch_K ${gen_arch_f} " your file is present, there is some problem to put it in an archive"
            fi
        fi
    else
        prb_arch_ gen_arch_K ${gen_arch_f} " your file is not present or not a regular file or not readable or of null size" "If it is not readable do a 'chmod 644 $gen_arch_f'"
    fi
done
if [ ${gen_arch_K} -gt 0 ]
then
    if [ -s $gen_arch_TARFILE ]
    then
        msg_ 1 "There is at least one missing file in your archive !"
    else
        msg_ 2 "Archive is empty or not generated ?" 
    fi
fi
if [ -s $gen_arch_TARFILE ]
then
   ae_echo_ "Compressing archive"
   gzip $gen_arch_TARFILE
   if [ $? -eq 0 ]
   then
       EVALARCH=${gen_arch_TARFILE}.gz
       msg_ 4 "Archive ${gen_arch_TARFILE}.gz ready to be auto evaluated or uploaded on the server."
    else
        ae_echo_  "Problem while compressing your archive !!! Check quota, $gen_arch_TARFILE and try again."
    fi
else
    if [ ${gen_arch_K} -eq 0 ]
    then
        msg_ 3 "Archive is empty or not generated but no file problem was identified ??"
    fi
fi
ae_echo_ -e "\n\n\n"
}
############################################################################################################################
#  CONFIG
############################################################################################################################
clear;
MYNAME=$0
echo "$MYNAME"
MYNAMESED=`echo "$MYNAME" | sed 's/\\//\\\\\\//g' | sed 's/\\./\\\\\\./g' `
CURDIR=`pwd`
TMPDIR=${CURDIR}/.auto_eval
AUTODIR=${CURDIR}/auto_eval_dir$$
clean_tmpdir_
mkdir $TMPDIR
trap "clean_tmpdir_;clean_autodir_;" 0
LABN=4
VERSION=0.5
YEAR=2018
TARFILE="./archive_lab4"
EVALARCH=''
cat<<FFN >$TMPDIR/ffn
trapTemplateGeneral.h
trapTemplateGeneral_imp.h
trapTemplate.h
trapTemplate_imp.h
objFunc.cc
objFunc.h
func.h
func.cc
Real1.cc
Real1.h
PolyTemplate.h
PolyTemplate_imp.h
Real2.cc
Real2.h
PolyTemplateSTL.h
FFN
cat<<FTS >$TMPDIR/fts
list_of_ex
list_of_ex_coef
test_trapTemplate.cc
test_trapTemplate.reg
test_trapTemplate_00.dat
test_trapTemplate_00.sol
test_GtrapTemplate.cc
test_GtrapTemplate.reg
test_GtrapTemplate_00.dat
test_GtrapTemplate_00.sol
test_PolyTemplate_d.cc
test_PolyTemplate_d.reg
test_PolyTemplate_d_00.dat
test_PolyTemplate_d_00.sol
test_PolyTemplate_r.cc
test_PolyTemplate_r.reg
test_PolyTemplate_r_00.dat
test_PolyTemplate_r_00.sol
FTS
cat<<FTS1 >$TMPDIR/list_of_ex
test_trapTemplate objFunc 
test_GtrapTemplate Real1 func 
test_PolyTemplate_d
test_PolyTemplate_r Real2
FTS1
cat<<FTS2 >$TMPDIR/list_of_ex_coef
1
1
1
1
1
FTS2
cat<<FTS3 >$TMPDIR/test_trapTemplate.cc
#include <iostream>
#include <cmath>
using namespace std;

#include "trapTemplate.h"
#include "objFunc.h"

int main()
{
    // integration setting
    double a = 0., b = 1.;
    int nbi;

    cout << "Give number of interval "<< endl;
    cin >> nbi;

    //local
    double res;
    double resref=acos(-1.);

    res=trapTemplate(a,b,nbi,unitCircleOF());
    cout << "PI : "<<res<< endl ;
    cout << "ERRORPI : "<<(resref-res)/resref<< endl ;

    res=trapTemplate(a,b,nbi,lineOF());
    cout << "LINE : "<<res<< endl ;
    cout << "ERRORLINE : "<<(0.5-res)/0.5<< endl ;

    res=trapTemplate(a,b,nbi,trigoOF());
    resref=(1.-cos(15.))/15.+sin(3.)/3.;
    cout << "TRIGO : "<<res<< endl ;
    cout << "ERRORTRIGO : "<<(resref-res)/resref<< endl ;

    res=trapTemplate(a,b,nbi,bilineOF());
    cout << "BILINE : "<<res<< endl ;
    cout << "ERRORBILINE : "<<(0.25-res)/0.25<< endl ;

    return 0;
}
FTS3
cat<<FTS4 >$TMPDIR/test_trapTemplate.reg
PI:R:1
ERRORPI:R:1
LINE:R:1
ERRORLINE:R:1
TRIGO:R:1
ERRORTRIGO:R:1
BILINE:R:1
ERRORBILINE:R:1
FTS4
cat<<FTS5 >$TMPDIR/test_trapTemplate_00.dat
11
FTS5
cat<<FTS6 >$TMPDIR/test_trapTemplate_00.sol
3.10945
0.0102319
0.5
0
0.145292
0.115971
0.247934
0.00826446
FTS6
cat<<FTS7 >$TMPDIR/test_GtrapTemplate.cc
#include <iostream>
#include <cmath>
using namespace std;

#include "trapTemplateGeneral.h"
#include "func.h"
#include "Real1.h"

int main()
{
    // first enter nb of intervals
    int nbi;
    cout << "Give number of interval "<< endl;
    cin >> nbi;

    // integer arithmetic
    // It is just to check that it is functional : it compile and run
    // It doesn't have any sense and give stupid results
    // ==============================================================================
    {
        // integration setting
        int a = 0, b = 1;

        // compute and display
        int res = trapTemplateGeneral(a,b,nbi,line);
        cout << "LINE : "<<res<< endl;

    }
    // float arithmetic
    // ==============================================================================
    {
        // integration setting
        float a = 0.F, b = 1.F;

        // compute and display
        float res = trapTemplateGeneral(a,b,nbi,biline);
        cout << "BILINE : "<<res<< endl;
        cout << "ERRORBILINE : "<<( 0.25F-res )/0.25F<< endl;

    }
    // double arithmetic
    // ==============================================================================
    {
        // integration setting
        double a = 0., b = 1.;

        // compute and display
        double res = trapTemplateGeneral(a,b,nbi,unitCircle);
        cout << "PI : "<<res<< endl;
        cout << "ERRORPI : "<<( acos(-1.)-res )/acos(-1.)<< endl;
        res = trapTemplateGeneral(a,b,nbi,trigo);
        double resref = ( 1.-cos(15.))/15.+sin(3.)/3.;
        cout << "TRIGO : "<<res<< endl;
        cout << "ERRORTRIGO : "<<( resref-res )/resref<< endl;

    }
    // Real arithmetic
    // ==============================================================================
    {
        // integration setting
        Real a = 0., b(1.,20);

        // compute and display
        Real res = trapTemplateGeneral(a,b,nbi,rline);
        Real resref (0.5,40);
        Real one (0.1,1);
        cout << "RLINE : "<<res<< endl;
        // Note that if res == resref, the error will be 1 and not 0. ERRORLINE should be equal to (res-resref)/resref
        // but we chose this formula to avoid rounding problems
        cout << "ERRORRLINE : "<<res/resref<< endl ;
    }
    return 0;
}
FTS7
cat<<FTS8 >$TMPDIR/test_GtrapTemplate.reg
LINE:R:1
BILINE:R:1
ERRORBILINE:R:1
PI:R:1
ERRORPI:R:1
TRIGO:R:1
ERRORTRIGO:R:1
RLINE:E:1
ERRORRLINE:E:1
FTS8
cat<<FTS9 >$TMPDIR/test_GtrapTemplate_00.dat
11
FTS9
cat<<FTS10 >$TMPDIR/test_GtrapTemplate_00.sol
0
0.247934
0.00826454
3.10945
0.0102319
0.145292
0.115971
0.5 40
0.1 1
FTS10
cat<<FTS11 >$TMPDIR/test_PolyTemplate_d.cc
#include <iostream>
#include "PolyTemplate.h"

using namespace std;

int main()
{
    // WARNING: the degree of all polynomials in this test program has to be
    // less than 9 (10 coefficients)

    double coef1[10] = {0.};
    double coef2[10] = {0.};
    int n1, n2;

    // Input polynomials
    cout << " === Testing template Poly class for double === " << endl;
    cout << "Input degree of p1d: ";
    cin >> n1;
    cout << "Input coefficients of p1d: " << endl;
    for (int i = 0; i <= n1; i++)
    {
        cin >> coef1[i];
    }

    cout << "Input degree of p2d: ";
    cin >> n2;
    cout << "Input coefficients of p2d: " << endl;
    for (int i = 0; i <= n2; i++)
    {
        cin >> coef2[i];
    }

    Poly < double > p1d(coef1,n1);

    // Try do create a polynomial of degree n1 with a null order n1 coefficient
    try
    {
        Poly < double > p3d(coef1,n1+1);
    }
    catch (int e)
    {
        cout <<"Error: trying to create a polynomial of order n with null coefficient of order n" <<endl;
    }
    Poly < double > p2d(coef2,n2);

    // Test polynomial methods and operators
    cout << " Test print(): " << endl;
    cout<<"p1d: ";
    p1d.print();
    cout<<"p2d: ";
    p2d.print();

    cout << " Test addition: " << endl;
    Poly < double > padd = p1d+p2d;
    cout<<"p1d+p2d: ";
    padd.print();
    Poly < double > padd2 = p2d+p1d;
    cout<<"p2d+p1d: ";
    padd2.print();

    cout << " Test substraction: " << endl;
    cout<<"p1d-p2d: ";
    Poly < double > pneg = p1d-p2d;
    pneg.print();
    cout<<"p2d-p1d: ";
    Poly < double > pneg2 = p2d-p1d;
    pneg2.print();

    cout << " Test multiplication: " << endl;
    cout<<"p1d*p2d: ";
    Poly < double > pprod = p1d*p2d;
    pprod.print();
    cout<<"p2d*p1d: ";
    Poly < double > pprod2 = p2d*p1d;
    pprod2.print();

    cout << " Test euclidian division: " << endl;
    Poly < double > pdivQ = pprod.euclidienDivisionQ(p1d);
    cout<<"Q=(p2d*p1d)/p1d=p2d: ";
    pdivQ.print();
    Poly < double > pdivQ2 = p2d.euclidienDivisionQ(p1d);
    cout<<"Q=p2d/p1d: ";
    pdivQ2.print();
    Poly < double > pdivR = pprod.euclidienDivisionR(p1d,pdivQ);
    cout<<"R=p2d-(p2d*p1d)/p1d=0: ";
    pdivR.print();
    Poly < double > pdivR2 = p2d.euclidienDivisionR(p1d,pdivQ2);
    cout<<"R=p2d-p2d/p1d: ";
    pdivR2.print();

    cout << "Testing () operator " << endl;
    double x;
    cout<<"First try, input a value for x1: " << endl;
    cin >> x;
    cout << "p1d(x1): "<<p1d(x) <<endl;
    cout << "p2d(x1): "<<p2d(x) <<endl;
    cout<<"Second try, input a value for x2: " << endl;
    cin >> x;
    cout << "p1d(x2): "<<p1d(x) <<endl;
    cout << "p2d(x2): "<<p2d(x) <<endl;


    return 0;
}

FTS11
cat<<FTS12 >$TMPDIR/test_PolyTemplate_d.reg
Error:T:1
p1d:T:1/2
p2d:T:1/2
p1d+p2d:T:1/2
p2d+p1d:T:1/2
p1d-p2d:T:1/2
p2d-p1d:T:1/2
p1d\\*p2d:T:1/2
p2d\\*p1d:T:1/2
Q=(p2d\\*p1d)/p1d=p2d:T:1/2
Q=p2d/p1d:T:1/2
R=p2d-(p2d\\*p1d)/p1d=0:T:1/2
R=p2d-p2d/p1d:T:1/2
p1d(x1):R:1/4
p2d(x1):R:1/4
p1d(x2):R:1/4
p2d(x2):R:1/4
FTS12
cat<<FTS13 >$TMPDIR/test_PolyTemplate_d_00.dat
3
3
2
0
7
5
1
0
3
0
7
1
0.5
3
FTS13
cat<<FTS14 >$TMPDIR/test_PolyTemplate_d_00.sol
trying to create a polynomial of order n with null coefficient of order n
poly(x)=3+2*x^1+7*x^3
poly(x)=1+3*x^2+7*x^4+1*x^5
poly(x)=4+2*x^1+3*x^2+7*x^3+7*x^4+1*x^5
poly(x)=4+2*x^1+3*x^2+7*x^3+7*x^4+1*x^5
poly(x)=2+2*x^1-3*x^2+7*x^3-7*x^4-1*x^5
poly(x)=-2-2*x^1+3*x^2-7*x^3+7*x^4+1*x^5
poly(x)=3+2*x^1+9*x^2+13*x^3+21*x^4+38*x^5+2*x^6+49*x^7+7*x^8
poly(x)=3+2*x^1+9*x^2+13*x^3+21*x^4+38*x^5+2*x^6+49*x^7+7*x^8
poly(x)=1+3*x^2+7*x^4+1*x^5
poly(x)=-0.0408163+1*x^1+0.142857*x^2
poly(x)=0
poly(x)=1.12245-2.91837*x^1+0.571429*x^2
4.875
2.21875
198
838
FTS14
cat<<FTS15 >$TMPDIR/test_PolyTemplate_r.cc
#include <iostream>
#include "PolyTemplate.h"
#include "Real2.h"

using namespace std;

int main()
{
    // WARNING: the degree of all polynomials in this test program has to be
    // less than 9 (10 coefficients)

    Real coef1[10];
    Real coef2[10];
    int n1, n2;
    double m;
    int e;

    // Input polynomials
    cout << " === Testing template Poly class for Real numbers === " << endl;
    cout << "Input degree of p1r: ";
    cin >> n1;
    cout << "Input coefficients of p1r (mantissa first, then exponent): " << endl;
    for (int i = 0; i <= n1; i++)
    {
        cin >> m >> e;
        coef1[i] = Real(m,e);
        cout << endl;
    }

    cout << "Input degree of p2r: ";
    cin >> n2;
    cout << "Input coefficients of p2r (mantissa first, then exponent): " << endl;
    for (int i = 0; i <= n2; i++)
    {
        cin >> m >> e;
        coef2[i] = Real(m,e);
        cout << endl;
    }

    Poly < Real > p1r(coef1,n1);

    // Try do create a polynomial of degree n1 with a null order n1 coefficient
    try
    {
        Poly < Real > p3r(coef1,n1+1);
    }
    catch (int e)
    {
        cout <<"Error: trying to create a polynomial of order n with null coefficient of order n" <<endl;
    }
    Poly < Real > p2r(coef2,n2);

    // Test polynomial methods and operators
    cout << " Test print(): " << endl;
    cout<<"p1r: ";
    p1r.print();
    cout<<"p2r: ";
    p2r.print();

    cout << " Test addition: " << endl;
    Poly < Real > padd = p1r+p2r;
    cout<<"p1r+p2r: ";
    padd.print();
    Poly < Real > padd2 = p2r+p1r;
    cout<<"p2r+p1r: ";
    padd2.print();

    cout << " Test substraction: " << endl;
    cout<<"p1r-p2r: ";
    Poly < Real > pneg = p1r-p2r;
    pneg.print();
    cout<<"p2r-p1r: ";
    Poly < Real > pneg2 = p2r-p1r;
    pneg2.print();

    cout << " Test multiplication: " << endl;
    cout<<"p1r*p2r: ";
    Poly < Real > pprod = p1r*p2r;
    pprod.print();
    cout<<"p2r*p1r: ";
    Poly < Real > pprod2 = p2r*p1r;
    pprod2.print();

    cout << " Test euclidian division: " << endl;
    Poly < Real > pdivQ = pprod.euclidienDivisionQ(p1r);
    cout<<"Q=(p2r*p1r)/p1r=p2r: ";
    pdivQ.print();
    Poly < Real > pdivQ2 = p2r.euclidienDivisionQ(p1r);
    cout<<"Q=p2r/p1r: ";
    pdivQ2.print();
    Poly < Real > pdivR = pprod.euclidienDivisionR(p1r,pdivQ);
    cout<<"R=p2r-(p2r*p1r)/p1r=0: ";
    pdivR.print();
    Poly < Real > pdivR2 = p2r.euclidienDivisionR(p1r,pdivQ2);
    cout<<"R=p2r-p2r/p1r: ";
    pdivR2.print();


    cout << "Testing () operator " << endl;
    cout<<"First try, input a value for x1 (mantissa first, then exponent): " << endl;
    cin >> m >> e;
    Real x(m,e);
    cout << "p1r(x1): "<<p1r(x) <<endl;
    cout << "p2r(x1): "<<p2r(x) <<endl;
    cout<<"Second try, input a value for x2 (mantissa first, then exponent): " << endl;
    cin >> m >> e;
    Real y(m,e);
    cout << "p1r(x2): "<<p1r(y) <<endl;
    cout << "p2r(x2): "<<p2r(y) <<endl;

    return 0;
}

FTS15
cat<<FTS16 >$TMPDIR/test_PolyTemplate_r.reg
p1r:T:1/2
p2r:T:1/2
p1r+p2r:T:1/2
p2r+p1r:T:1/2
p1r-p2r:T:1/2
p2r-p1r:T:1/2
p1r\\*p2r:T:1/2
p2r\\*p1r:T:1/2
Q=(p2r\\*p1r)/p1r=p2r:T:1/2
Q=p2r/p1r:T:1/2
R=p2r-(p2r\\*p1r)/p1r=0:T:1/2
R=p2r-p2r/p1r:T:1/2
p1r(x1):E:1/4
p2r(x1):E:1/4
p1r(x2):E:1/4
p2r(x2):E:1/4
Error:T:1
FTS16
cat<<FTS17 >$TMPDIR/test_PolyTemplate_r_00.dat
1
1
0
2
0
2
0
0
1
0
2
5
4
658
5
-2
FTS17
cat<<FTS18 >$TMPDIR/test_PolyTemplate_r_00.sol
poly(x)=0.1E1+0.2E1*x^1
poly(x)=+0.1E1*x^1+0.2E6*x^2
poly(x)=0.1E1+0.3E1*x^1+0.2E6*x^2
poly(x)=0.1E1+0.3E1*x^1+0.2E6*x^2
poly(x)=0.1E1+0.1E1*x^1-0.2E6*x^2
poly(x)=-0.1E1-0.1E1*x^1+0.2E6*x^2
poly(x)=+0.1E1*x^1+0.200002E6*x^2+0.4E6*x^3
poly(x)=+0.1E1*x^1+0.200002E6*x^2+0.4E6*x^3
poly(x)=+0.1E1*x^1+0.2E6*x^2
poly(x)=-0.499995E5+0.1E6*x^1
poly(x)=0E0
poly(x)=0.499995E5+0.100999E-9*x^1
0.8 659
0.32 1323
0.11 1
0.50005 3
trying to create a polynomial of order n with null coefficient of order n
FTS18
EPSILON_RES=1.e-10
if [ !  -s $TMPDIR/list_of_ex  ]
then
    msg_ 3 "Configuration problem : $TMPDIR/list_of_ex not present. Rebuild $MYNAME"
    exit 1
fi
NBEXE=`cat $TMPDIR/list_of_ex | wc -l| cut -d' ' -f1`
if [ ! -s $TMPDIR/list_of_ex_coef  ]
then
    msg_ 3 "Configuration problem : $TMPDIR/list_of_ex_coef not present. Rebuild $MYNAME"
    exit 1
fi
SUMCOEF=`cat $TMPDIR/list_of_ex_coef | awk 'BEGIN{s=0.;}{s+=\$1}END{print s}'`
LOGFILE=/dev/null
LOGYN=0
while [ $# -gt 0 ]
do
    case $1 in
        -h)
            echo "Usage :"
            echo -e "\n  "`basename $MYNAME`" [OPTION]\n"
            echo "With OPTION from following :"
            echo -e "\t-h : This message."
            echo -e "\t-l : Log you session (what you see on the screen and your answers) in a file."
            echo "";
            exit 0;;
        -l)
            LOGYN=1;
            LOGFILE=${CURDIR}/$$_auto_eval.log
            echo -e "Your session will be logged in "`basename $LOGFILE`"\n";;
        -x)
            set -x;;
    esac
    shift;
done
############################################################################################################################
#  PRG
############################################################################################################################
choose_group_ GROUP_ID
while [ "$first_choice_C" != "q" ]
do
    first_choice_
    case $first_choice_C in
        a)
            gen_arch_;;
        b)
            for eval_arch_ in eval_arch_check_ eval_arch_genrep_ eval_arch_unpack_ eval_arch_compil_ eval_arch_run_ eval_arch_diff_
            do
                eval $eval_arch_;
                if [ $? -ne 0 ]
                then
                    break;
                fi
            done
            cd $CURDIR;;
        c)
            cd $AUTODIR;
            disp_diff_arch_;
            cd $CURDIR;;
    esac
done
