BACKUP_COUNT=`ls $ROTATE_FOLDER/$ROTATE_FILTER | wc -l`
while [ "${BACKUP_COUNT}" -gt "${ROTATE_MAX}" ]; do
  OLDEST=`ls $ROTATE_FOLDER/$ROTATE_FILTER | head -1`
  # echo "* Removing old backup file ${OLDEST}"
  rm $OLDEST
  BACKUP_COUNT=`ls $ROTATE_FOLDER/$ROTATE_FILTER | wc -l`
done
