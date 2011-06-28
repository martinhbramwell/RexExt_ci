if ps aux | grep rexster | grep -cv grep > 0
then 
	echo "Rexster Up."
else 
	echo "Rexster Down."
fi

