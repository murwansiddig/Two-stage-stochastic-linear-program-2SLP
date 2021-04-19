data_file = read("20x20-1-20000-1-clean.dat",String);
data_file = split(data_file, "\n");

#1st row contains = [nbFirstVars, nbSecVars, nbScens, nbFirstRows, nbSecRows]
first_row=[];
temp = data_file[1][2:end-1];
temp = split(temp, ",");
for i=1:length(temp)
    push!(first_row, parse(Float64,temp[i]))
end
nbFirstVars = convert(Int64,first_row[1]); #The number of 1st stage variables
nbSecVars = convert(Int64,first_row[2]); #The number of 2nd stage variables
nbScens = convert(Int64,first_row[3]); #The number of scenarios
nbFirstRows = convert(Int64,first_row[4]); #The number of first stage constraints
nbSecRows = convert(Int64,first_row[5]); #The number of second stage constraints

#2nd row contains, objcoef = [firststage coef, secondstage coef] 
#(already scaled by # of scenarios, second-stage coef is the same for all scenarios so we only need one copy)
second_row=[];
temp = data_file[2][2:end-1];
temp = split(temp, ",");
for i=1:length(temp)
    push!(second_row, parse(Float64,temp[i]))
end
objcoef = second_row;

#3rd & 4th row contain the 1st stage variables LB and UB
third_row=[];
temp = data_file[3][2:end-1];
temp = split(temp, ",");
for i=1:length(temp)
    push!(third_row, parse(Float64,temp[i]))
end
firstvarlb = third_row;

fourth_row=[];
temp = data_file[4][2:end-1];
temp = split(temp, ",");
for i=1:length(temp)
    push!(fourth_row, parse(Float64,temp[i]))
end
firstvarub = fourth_row;

#5th & 6th row contain the 2nd stage variables LB and UB for the k scenarios; secondvarlb[k*prob.nbSecVars+i], k loops scenarios, i loops # of second-stage variables 
fifth_row=[];
temp = data_file[5][2:end-1];
temp = split(temp, ",");
for i=1:length(temp)
    push!(fifth_row, parse(Float64,temp[i]))
end
secondvarlb = fifth_row;
secondvarlb = reshape(secondvarlb, nbSecVars,nbScens);
secondvarlb = secondvarlb';

sixth_row=[];
temp = data_file[6][2:end-1];
temp = split(temp, ",");
for i=1:length(temp)
    push!(sixth_row, parse(Float64,temp[i]))
end
secondvarub = sixth_row;
secondvarub = reshape(secondvarub, nbSecVars, nbScens)
secondvarub = secondvarub';


#7th & 8th row contain the first stage constraint variables indices and coefficients (firstconstrind and coef)
firstconstrind = [];
for i=1:nbFirstRows
    firstconstrindlist=[];
    TMEP = [];
    if i == 1 
        TMEP = data_file[6+i][3:end-2];
    else
        TMEP = data_file[6+i][2:end-2];        
    end
    TMEP = split(TMEP, ",");
    for j=1:length(TMEP)
        push!(firstconstrindlist, parse(Int64,TMEP[j])+1)
    end
    push!(firstconstrind, firstconstrindlist);
end


firstconstrcoef = [];
for i=1:nbFirstRows
    firstconstrindlist=[];
    TMEP = [];
    if i == 1 
        TMEP = data_file[6+nbFirstRows+i][3:end-2];
    else
        TMEP = data_file[6+nbFirstRows+i][2:end-2];        
    end
    TMEP = split(TMEP, ",");
    for j=1:length(TMEP)
        push!(firstconstrindlist, parse(Float64,TMEP[j]))
    end
    push!(firstconstrcoef, firstconstrindlist);
end


#9th & 10th row contain the first stage constraints LB & UB (firstconstrlb and firstconstrub)

ninth_row=[];
temp = data_file[7+nbFirstRows+nbFirstRows][2:end-1];
temp = split(temp, ",");
for i=1:length(temp)
    push!(ninth_row, parse(Float64,temp[i]))
end
firstconstrlb = ninth_row;


tenth_row=[];
temp = data_file[8+nbFirstRows+nbFirstRows][2:end-1];
temp = split(temp, ",");
for i=1:length(temp)
    push!(tenth_row, parse(Float64,temp[i]))
end
firstconstrub = tenth_row;

#11th row contains the nbPerRow: number of variables (including first stage and second stage variables) in each row of the second stage constraint matrix
eleventh_row=[];
temp = data_file[9+nbFirstRows+nbFirstRows][2:end-1];
temp = split(temp, ",");
for i=1:length(temp)
    push!(eleventh_row, parse(Float64,temp[i]))
end
nbPerRow = eleventh_row;

#12th & 13th row contain the second stage constraint bound (arranged in a Matrix = row is scenario & coloumn is the constraint) & sense (secondconstrbd and secondconstrsense) 
twelfth_row=[];
temp = data_file[10+nbFirstRows+nbFirstRows][2:end-1];
temp = split(temp, ",");
for i=1:length(temp)
    push!(twelfth_row, parse(Float64,temp[i]))
end
secondconstrbd = twelfth_row;
secondconstrbd = reshape(secondconstrbd, nbSecRows, nbScens)
secondconstrbd = secondconstrbd';


thirteenth_row=[];
temp = data_file[11+nbFirstRows+nbFirstRows][2:end-1];
temp = split(temp, ",");
for i=1:length(temp)
    push!(thirteenth_row, parse(Float64,temp[i]))
end
secondconstrsense = thirteenth_row;

#14th & 15th row contain the second stage constraint variables indices and coefficients (CoefMat and CoefInd)
secondconstrind = []
for i=1:nbSecRows
    fourteenth_row=[];
    TMEP = [];
    if i == 1 
        TMEP = data_file[11+nbFirstRows+nbFirstRows+nbSecRows+i][3:end-2];
    else
        TMEP = data_file[11+nbFirstRows+nbFirstRows+nbSecRows+i][2:end-2];        
    end
    TMEP = split(TMEP, ",");
    for j=1:length(TMEP)
        push!(fourteenth_row, parse(Int64,TMEP[j])+1)
    end
    secondconstrindlist= fourteenth_row
    push!(secondconstrind, secondconstrindlist);
end
#We will split the list of indices into two lists, indices of the 1st stage variable and the second
second1stconstrind = []
second2ndconstrind = []
for i=1:nbSecRows
    second1stconstrindlist = []
    second2ndconstrindlist = []
    for j=1:length(secondconstrind[i])
        if secondconstrind[i][j] <= nbFirstVars
            push!(second1stconstrindlist,secondconstrind[i][j])
        else
            push!(second2ndconstrindlist,secondconstrind[i][j]-nbFirstVars)
        end
    end
    push!(second1stconstrind,second1stconstrindlist)
    push!(second2ndconstrind,second2ndconstrindlist)
end


secondconstrcoef = []
for i=1:nbSecRows
    fifteenth_row = [];
    TMEP = [];
    if i == 1 
        TMEP = data_file[11+nbFirstRows+nbFirstRows+i][3:end-2];
    else
        TMEP = data_file[11+nbFirstRows+nbFirstRows+i][2:end-2];        
    end
    TMEP = split(TMEP, ",");
    for j=1:length(TMEP)
        push!(fifteenth_row, parse(Float64,TMEP[j]))
    end
    secondconstrcoeflist= fifteenth_row
    push!(secondconstrcoef, secondconstrcoeflist);
end
#We will split the list of coefficient into two lists, coefficients of the 1st stage variable and the second

second1stconstrcoef = []
second2ndconstrcoef = []
for i=1:nbSecRows
    second1stconstrcoeflist = []
    second2ndconstrcoeflist = []
    for j=1:length(secondconstrcoef[i])
        if j <= length(second1stconstrind[i])
            push!(second1stconstrcoeflist,secondconstrcoef[i][j])
        else
            push!(second2ndconstrcoeflist,secondconstrcoef[i][j])
        end 
    end
    push!(second1stconstrcoef,second1stconstrcoeflist)
    push!(second2ndconstrcoef,second2ndconstrcoeflist)
end




