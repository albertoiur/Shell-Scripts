#!/bin/ksh

USER=~itx
DIR_CFG=${USER}/cfg
FILE_TELEFONE=${DIR_CFG}/"envia_sms.telefones"
ESPACO_LIMITE=80 # VALOR EM PERCENTAGEM
DATA_PROCESSAMENTO=`date +"%Y%m%d%H%M%s"`
MAQUINA=akpix345
SISTEMAS=itx
DIR_LOG=${USER}/log
FILE_LOG=${DIR_LOG}/outros/$(basename $0 .sh)".log"
MAX_ALARMES_SEM_SMS=10

#Parametro 1 = Sistema, Parametro 2 = Percentagem de espaco

FUNCAO_envia_sms()
{
  for num in $(cat ${FILE_TELEFONE})
  do
    echo "ATENCAO: Espaco no user ${1} maquina $MAQUINA em ${2}% - limite maximo
    em ${ESPACO_LIMITE}%" | enviasms -nolog 96 $num
  done
}

#Parametro 1 : FLAG_STOP

FUNCAO_alarmes_flag_stop()
{
  FILE_FLAG_STOP=$1

  if [ -s ${FILE_FLAG_STOP} ]
  then
    NUMERO_ALARMES=$(tail -1 ${FILE_FLAG_STOP})
  else
    NUMERO_ALARMES=0
  fi

  echo ${NUMERO_ALARMES}
}

#### Main ###

for SISTEMA in $SISTEMAS
do
  ESPACO=$(df -k -P ~${SISTEMA} | tail -1 | gawk '{print $5}' | sed "s/[|%]//g")
  FLAG_STOP=${USER}/cfg/$(basename $0 .sh)".flag_${SISTEMA}.stop"

  if [ $ESPACO -gt $ESPACO_LIMITE]
  then
    FUNCAO_envia_sms ${SISTEMA} ${ESPACO}
    echo "${DATA_PROCESSAMENTO}" - Espaco no user $SISTEMA maquina $MAQUINA em
    ${ESPACO}% - ATENCAO - SMS" >> ${FILE_LOG}
    echo "1" > ${FLAG_STOP}
  else
    num_alarme=$(FUNCAO_alarmes_flag_stop ${FLAG_STOP})
    if [ ${MAX_ALARMES_SEM_SMS} -gt ${num_alarme} ]
    then
      echo "${DATA_PROCESSAMENTO} - Espaco no user $SISTEMA maquina $MAQUINA em ${ESPACO}% ATENCAO"  >> ${FILE_LOG}
      let num_alarme = `expr ${num_alarme} + 1`
      echo ${num_alarme} > ${FLAG_STOP}
    else
      echo "1" > ${FLAG_STOP}
      echo "${DATA_PROCESSAMENTO} - Espaco no user $SISTEMA maquina $MAQUINA em ${ESPACO}% ATENCAO"  >> ${FILE_LOG}
      FUNCAO_envia_sms ${SISTEMA} ${ESPACO}
    fi
  fi
else
  echo "${DATA_PROCESSAMENTO} - Espaco no user $SISTEMA maquina ${MAQUINA} em ${ESPACO}% - Limite maximo em ${ESPACO_LIMITE}" >> ${FILE_LOG}
  if [ -e $FLAG_STOP ]
  then
    rm -f $FLAG_STOP
  fi
fi
done
