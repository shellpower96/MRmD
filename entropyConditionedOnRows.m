function entropy = entropyConditionedOnRows(matrix)
    sumValue = sum(matrix,2);
    temp = matrix .* log(matrix);
    temp(isnan(temp))=0;
    returnedValue = sum(sum(temp)) - sum(sumValue .*log(sumValue));
    total = sum(sumValue);

    if total ==0 
        entropy =0;
    else
        entropy =  - returnedValue /(total *log(2));
    end