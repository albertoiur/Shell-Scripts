#/bin/ksh

USER=~itx
DATA_PROCESSAMENTO=$(date +"%Y%m%d%H%M%S")
FILE_LOG=$(basename $0 .sh)".log"
DIR_EXEC=${USER}/bin
DIR_CFG=${USER}/cfg
KBYTES=50000

Funcao_Procurar_Ficheiros_Grandes()
{
find ~itx/ -deph -mount -type f -size +{KBYTES}k -exec ls -ld {} \;
2>/dev/null | sort -n -k 5.1,5 >> ${FILE_LOG}
}

Funcao_envia_mail()
{
  if [ -s ${FILE_LOG} ]
  then
    mensagem_email="ITX-GESTAO - ${DATA_PROCESSAMENTO} - Ficheiros com mais de ${KBYTES}"
    ${DIR_EXEC}/envia_mail.sh ${DIR_CFG}/envia_mail.enderecos "$mensagem_email" "$(cat ${FILE_LOG})"
  fi
}


### Main ###
Funcao_Procurar_Ficheiros_Grandes
Funcao_envia_mail

rm -f ${FILE_LOG}
