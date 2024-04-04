clear
set more off
cd /Users/polinapogorelova/Desktop/СМЭФ_Эконометрика
log using sem13.log

* Задание 1. Bootstrap
set seed 777 // для воспроизводимости результатов
set obs 1000 // число наблюдений

* Функция invnorm(uniform()) генерирует стандартную нормальную СВ

* Сгенерируем объясняющую переменную
gen x = invnorm(uniform())

* Сгенерируем остатки модели в виде нормально распределенной СВ с нулевым мат. ожиданием и дисперсией равной 3
gen e = sqrt(3)*invnorm(uniform())

* Сгенерируем зависимую переменную
gen y = 0.4*x + e

* Оценим по сгенерированным данным линейную модель регрессии без константы
reg y x, noc

* Сгенерируем B = 1000 бутстрапированных выборок (парный бустрап) для линейной регрессии и рассчитаем бутстрапированные 
* стандартные ошибки
bootstrap, reps(1000): reg y x

* t-перцентильные доверительные интервалы для коэффициентов
estat bootstrap, percentile

* Бутстрэп t-статистики:
reg y x
scalar b = _b[x]
bootstrap t=((_b[x]-b)/_se[x]), reps(999): reg y x, level(95)
estat bootstrap, percentile

* Можно создать программу для вычисления t-статистики
program tstat, rclass
reg y x
return scalar t = (_b[x]-b)/_se[x]
end

reg y x
scalar b = _b[x]
bootstrap t=r(t), reps(1000): tstat
estat bootstrap, percentile

reg y x
scalar b = _b[x]
bootstrap t=r(t), reps(999) saving(bs_t3): tstat
use bs_t3, replace
centile t, centile(2.5, 97.5)
gen t_abs = abs(t)
centile t_abs, centile(95)

reg y x
scalar b = 0.6
tstat
return list


* Задание 2. Квантильная регрессия
use https://stats.idre.ucla.edu/stat/stata/webbooks/reg/elemapi2
* api_00 (ACADEMIC PERFORMANCE INDICATORS) - индекс академической успеваемости
* acs_k3 - средний размер класса от K (Kindergarten, детский сад) до 3 
* acs_46 - средний размер класса от 4 до 6
* full - процент полностью аттестованных учителей
* enroll - количество учеников в школе

sum api00 acs_k3 acs_46 full enroll

reg api00 acs_k3 acs_46 full enroll
test acs_k3 acs_46

* График зависимости остатков от модельных значений
rvfplot

* Квантильная (медианная) регрессия
qreg api00 acs_k3 acs_46 full enroll

* График зависимости остатков от модельных значений медианной регрессии
predict p if e(sample)
predict r if e(sample), r
scatter r p, yline(0)

* Квантильная регрессия для квантилей разного уровня
qreg api00 acs_k3 acs_46 full enroll, quant(.05) 
qreg api00 acs_k3 acs_46 full enroll, quant(.25) 
qreg api00 acs_k3 acs_46 full enroll, quant(.50) 
qreg api00 acs_k3 acs_46 full enroll, quant(.75) 
qreg api00 acs_k3 acs_46 full enroll, quant(.95)

* Оценим модель сразу для нескольких квантилей
sqreg api00 acs_k3 acs_46 full enroll, q(.1 .9)
test [q10]enroll = [q90]enroll

* Bootstrap standard errors
set seed 1001

bsqreg api00 acs_k3 acs_46 full enroll

* Графики для оценок коэффициентов на разных уровнях квантилей
ssc install grqreg, replace

qreg api00 acs_k3 acs_46 full enroll
grqreg, cons ci  title(Fig.1a Fig.1b Fig.1c Fig.1d Fig.1e) 

qreg api00 acs_k3 acs_46 full enroll
grqreg, cons ci title(Fig.1a Fig.1b Fig.1c Fig.1d Fig.1e) qstep (0.1)

qreg api00 acs_k3 acs_46 full enroll
grqreg, cons ci  title(Fig.1a Fig.1b Fig.1c Fig.1d Fig.1e) qstep (0.2)

* Одновременное оценивание квантильных регрессий для разных уровней квантилей
set seed 1001

sqreg api00 acs_k3 acs_46 full enroll, q(.25 .5 .75)

* Можно протестировать гипотезу о равенстве коэффициентов при переменной full в модели для квантильных
* регрессий уровней 0.25 и 0.75
test[q25]full = [q75]full

* Доверительный интервал для разности коэффициентов при переменной full в модели для квантильных
* регрессий уровней 0.75 и 0.25
lincom [q75]full-[q25]full
