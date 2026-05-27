#!/bin/awk -f 
BEGIN{ FS="~"; OFS="~" }
{
    CTR_NF=$24;
    SEC_NF=$26;
    UWY_NF=$27;

    if ((index(CTR_NF, "04W059112") || index(CTR_NF, "04W059113")) && SEC_NF == 1 && UWY_NF > 1996)
        $27="1996";
                
    if (index(CTR_NF, "04W604280") && SEC_NF == 1 && UWY_NF > 1989)
        $27="1989";
               
    for(i=1;;i++)
    {       
        if (i == NF)
        {       
            printf("%s\n", $i);
            break;  
        }       
        else printf("%s~", $i);
    }
}
