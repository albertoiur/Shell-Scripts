#!/bin/ksh

USER=~itx
SPACES="itx_dbs1"
THRESHOLD=6
DIR_EXEC=${USER}/bin
DIR_CFG=${USER}/cfg
MAIL_ENDERECOS=${DIR_CFG}/envia_mail.enderecos
SMS_TELEFONES=${DIR_CFG}/envia_mail.telefones
DATA_PROCESSAMENTO=$(date +"%Y%m%d%H%M%S")
TEMP_FILE=controla_espaco_${DATA_PROCESSAMENTO}.temp
MAIL_FILE=controla_espaco_${DATA_PROCESSAMENTO}.mail

echo "Data: $(date +"%Y-%m-%d %H:%M:%S")" > $MAIL_FILE

for space in $SPACES:
do
  cat /dev/null > $TEMP_FILE

  ixspaces | awk -v threshold="$THRESHOLD" -v space="$space" -v temp_file="TEMP_FILE" 'BEGIN{FS=" "}
  {
    if ($2 == space)
    {
      printf("\n")
      printf("DBSpace = %s\n",space);
      printf("Total = %d Kib\n", $3*1024);
      printf("Livre = %d Kib\n", $4*1024);
      printf("Percentagem Livre = %3.2f%\n\n", $6);
      printf(($6<threshold)*$6) > temp_file;
    }
  }' >> ${MAIL_FILE}

  if [ -s $TEMP_FILE ]
  then
    valor=$(cat $TEMP_FILE)

    if [ valor -ne 0 ]
    then
      for num in `cat ${SMS_TELEFONES}`
      do
        echo "Atencao: $space inferior a $THRESHOLD% ($valor%)." | enviasms -nolog 1234 $num
      done
    fi
  else
    echo "Sem dados para DBSpace: $space" >> ${MAIL_FILE}
  fi
done

${DIR_EXEC}/envia_mail2.sh ${MAIL_ENDERECOS} "Espaco Livre DBspace" ${MAIL_FILE}

rm -f $TEMP_FILE
rm -f $MAIL_FILE





  '
