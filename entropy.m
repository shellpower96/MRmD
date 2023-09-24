function entro = entropy(array)
sumValue = sum(array);
temp = array .*log(array);
temp(isnan(temp))=0;
returnedValue = sum(-temp);

if sumValue ==0
    entro = 0;
else
    entro = (returnedValue + sumValue *log(sumValue))/ (sumValue *log(2));
end