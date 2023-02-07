### sigprofiler

python3

from SigProfilerMatrixGenerator.scripts import SigProfilerMatrixGeneratorFunc as matGen
# WT
matrices = matGen.SigProfilerMatrixGeneratorFunc("WT", "mm10", "/media/thong/Maico/16052021/SigProfiler/WT",plot=True)
# KO
matrices = matGen.SigProfilerMatrixGeneratorFunc("KO", "mm10", "/media/thong/Maico/16052021/SigProfiler/KO",plot=True)

### extract 
from SigProfilerExtractor import sigpro as sig
# WT
sig.sigProfilerExtractor("vcf", "WT_results_500rep", "/media/thong/Maico/16052021/SigProfiler/WT", "mm10", minimum_signatures=1, maximum_signatures=10, nmf_replicates=500)
# KO
sig.sigProfilerExtractor("vcf", "KO_results_500rep", "/media/thong/Maico/16052021/SigProfiler/KO", "mm10", minimum_signatures=1, maximum_signatures=10, nmf_replicates=500)
