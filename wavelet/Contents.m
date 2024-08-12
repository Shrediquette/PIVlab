% Wavelet Toolbox
% Version 6.2 (R2022b) 13-May-2022
%
%
% Wavelet: General
%   biorfilt        - Biorthogonal wavelet filter set
%   centfrq         - Wavelet center frequency
%   cwtfilterbank   - CWT filter bank
%   dwtfilterbank   - DWT filter bank
%   dyaddown        - Dyadic downsampling
%   dyadup          - Dyadic upsampling
%   intwave         - Integrate wavelet function psi
%   isbiorthwfb     - True for biorthogonal wavelet filter bank
%   isorthwfb       - True for orthogonal wavelet filter bank
%   orthfilt        - Orthogonal wavelet filter set
%   qmf             - Quadrature mirror filter
%   qbiorthfilt     - First-level dual-tree biorthogonal filters
%   scal2frq        - Scale to frequency
%   wavefun         - Wavelet and scaling functions
%   wavefun2        - Wavelet and scaling functions 2-D
%   wavemngr        - Wavelet manager 
%   wfilters        - Wavelet filters
%   wmaxlev         - Maximum wavelet decomposition level
%
% Wavelet Families
%   biorwavf        - Biorthogonal spline wavelet filters
%   blscalf         - Best-localized Daubechies scaling filters
%   cgauwavf        - Complex Gaussian wavelet
%   cmorwavf        - Complex Morlet wavelet
%   coifwavf        - Coiflet wavelet filter
%   dbaux           - Daubechies wavelet filter computation
%   dbwavf          - Daubechies wavelet filters
%   fbspwavf        - Complex frequency B-spline wavelet
%   fejerkorovkin   - Fejer-Korovkin wavelet filters
%   gauswavf        - Gaussian wavelet
%   hanscalf        - Han orthogonal scaling filters
%   mbscalf         - Morris minimum-bandwidth orthogonal scaling filters
%   mexihat         - Mexican Hat wavelet
%   meyer           - Meyer wavelet
%   meyeraux        - Meyer wavelet auxiliary function
%   morlet          - Morlet wavelet
%   rbiowavf        - Reverse biorthogonal spline wavelet filters
%   shanwavf        - Complex Shannon wavelet
%   symaux          - Symlet wavelet filter computation
%   symwavf         - Symlet wavelet filter
%
% Time-Frequency Analysis/Synthesis
%   cqt             - Constant-Q transform using nonstationary Gabor frames
%   icqt            - Inverse constant-q transform using nonstationary Gabor frames
%   cwtft           - Continuous wavelet transform using DFT
%   icwtft          - Inverse continuous wavelet transform using FFT
%   cwtftinfo       - Information on wavelets for CWTFT
%   cwtfreqbounds   - CWT maximum and minimum period or frequency 
%   cwt             - Continuous wavelet transform
%   icwt            - Inverse continuous wavelet transform
%   icwtlin         - Inverse continuous wavelet transform using linear scales
%   cwtfilterbank   - CWT filter bank
%   timeSpectrum    - Time-averaged wavelet spectrum (cwtfilterbank)
%   scaleSpectrum   - Scale-averaged wavelet spectrum (cwtfilterbank)
%   emd             - Empirical mode decomposition
%   hht             - Hilbert-Huang transform
%   pat2cwav        - Construction of a wavelet starting from a pattern
%   wcoherence      - Wavelet coherence
%   wsst            - Wavelet synchrosqueezing transform
%   iwsst           - Inverse wavelet synchrosqueezing transform
%   wsstridge       - Time-frequency ridges from wavelet synchrosqueezing
%   wt              - Continuous wavelet transform (cwtfilterbank)
%   wtmm            - Wavelet transform modulus maxima
%   wscalogram      - Scalogram for continuous wavelet transform
%   wvd             - Wigner-Ville distribution and smoothed pseudo Wigner-Ville distribution
%   xwvd            - Cross Wigner-Ville distribution and cross smoothed pseudo Wigner-Ville distribution
%
% Deep Feature Extractors
%   waveletScattering   - Wavelet time scattering
%   waveletScattering2  - Wavelet image scattering
%
% Continuous Wavelet: Two-Dimensional
%   cwtft2          - 2-D Continuous wavelet transform
%   cwtftinfo2      - Information on wavelets for CWTFT2
%
% Discrete Multiresolution Analysis: One-Dimensional
%   appcoef                         - Extract 1-D approximation coefficients
%   detcoef                         - Extract 1-D detail coefficients
%   dualtree                        - Kingsbury Q-shift 1-D dual-tree complex wavelet transform
%   idualtree                       - 1-D inverse Kingsbury Q-shift dual-tree complex wavelet transform
%   dddtree                         - Forward real and complex double and double-density dual-tree 1-D DWT
%   idddtree                        - Inverse real and complex double and double-density dual-tree 1-D DWT
%   dddtreecfs                      - Extract or reconstruct dual-tree coefficients
%   dlmodwt                         - Deep learning maximal overlap discrete wavelet transform and MRA
%   dtfilters                       - Dual-tree filters
%   dwt                             - Single-level discrete 1-D wavelet transform
%   dwpt                            - Wavelet packet 1-D transform
%   dwtfilterbank                   - DWT filter bank
%   dwtmode                         - Discrete wavelet transform extension mode
%   ewt                             - Empirical wavelet transform
%   idwt                            - Single-level inverse discrete 1-D wavelet transform
%   idwpt                           - Inverse wavelet packet 1-D transform
%   haart                           - Haar 1-D transform
%   ihaart                          - Inverse Haar 1-D transform
%   mlpt                            - Multiscale local polynomial transform
%   imlpt                           - Inverse multiscale local polynomial transform
%   mlptrecon                       - Multiscale 1-D local polynomial transform reconstruction 
%   modwt                           - Maximal overlap discrete wavelet transform
%   imodwt                          - Inverse maximal overlap discrete wavelet transform
%   modwtmra                        - Maximal overlap discrete wavelet transform MRA
%   modwtcorr                       - Maximal overlap discrete wavelet transform correlation
%   modwtvar                        - Maximal overlap discrete wavelet transform variance
%   modwtxcorr                      - Maximal overlap discrete wavelet transform cross-correlation sequences
%   signalMultiresolutionAnalyzer   - Signal multiresolution analyzer app
%   iswt                            - Inverse discrete stationary wavelet transform 1-D
%   swt                             - Discrete stationary wavelet transform 1-D
%   upcoef                          - Direct reconstruction from 1-D wavelet coefficients
%   tqwt                            - Tunable Q-factor wavelet transform
%   itqwt                           - Inverse tunable Q-factor wavelet transform
%   tqwtmra                         - Tunable Q-factor multiresolution analysis  
%   upwlev                          - Single-level reconstruction of 1-D wavelet decomposition
%   vmd                             - Variational mode decomposition
%   wavedec                         - Multilevel 1-D wavelet decomposition
%   waverec                         - Multilevel 1-D wavelet reconstruction
%   wenergy                         - Energy for 1-D wavelet decomposition
%   wrcoef                          - Reconstruct single branch from 1-D wavelet coefficients
%
% Discrete Multiresolution Analysis: Two-Dimensional
%   appcoef2        - Extract 2-D approximation coefficients
%   detcoef2        - Extract 2-D detail coefficients
%   dualtree2       - Kingsbury Q-shift 2-D dual-tree complex wavelet transform
%   idualtree2      - 2-D inverse Kingsbury Q-shift Dual-tree complex wavelet transform
%   dddtree2        - Forward real and complex double and double-density 2-D dual-tree wavelet transform
%   idddtree2       - Inverse real and complex double and double-density 2-D dual-tree wavelet transform
%   dwt2            - Single-level discrete 2-D wavelet transform
%   dwtmode         - Discrete wavelet transform extension mode
%   haart2          - Haar 2-D transform
%   idwt2           - Single-level inverse discrete 2-D wavelet transform
%   ihaart2         - Inverse Haar 2-D transform
%   shearletSystem  - Bandlimited shearlet system
%   iswt2           - Inverse discrete stationary wavelet transform 2-D
%   swt2            - Discrete stationary wavelet transform 2-D
%   upcoef2         - Direct reconstruction from 2-D wavelet coefficients
%   upwlev2         - Single-level reconstruction of 2-D wavelet decomposition
%   wavedec2        - Multi-level 2-D wavelet decomposition
%   waverec2        - Multi-level 2-D wavelet reconstruction
%   wenergy2        - Energy for 2-D wavelet decomposition
%   wrcoef2         - Reconstruct single branch from 2-D wavelet coefficients
%
% Discrete Multiresolution Analysis: Three-Dimensional
%   dwt3        - Single-level discrete 3-D wavelet transform
%   dwtmode     - Discrete wavelet transform extension mode
%   dualtree3   - 3-D dual-tree wavelet transform
%   idualtree3  - 3-D dual-tree wavelet reconstruction
%   idwt3       - Single-level inverse discrete 3-D wavelet transform
%   wavedec3    - Multi-level 3-D wavelet decomposition
%   waverec3    - Multi-level 3-D wavelet reconstruction
%
% Wavelets Packets 
%   bestlevt        - Best level tree (wavelet packet)
%   besttree        - Best tree (wavelet packet)
%   entrupd         - Entropy update (wavelet packet)
%   modwpt          - Maximal overlap discrete wavelet packet transform
%   imodwpt         - Inverse maximal overlap discrete wavelet packet transform
%   modwptdetails   - Maximal overlap discrete wavelet packet details
%   wenergy         - Energy for a wavelet packet decomposition
%   wentropy        - Entropy (wavelet packet)
%   wp2wtree        - Extract wavelet tree from wavelet packet tree
%   wpcoef          - Wavelet packet coefficients
%   wpspectrum      - Wavelet packet spectrum
%   wpcutree        - Cut wavelet packet tree
%   wpdec           - Wavelet packet decomposition 1-D
%   wpdec2          - Wavelet packet decomposition 2-D
%   wpfun           - Wavelet packet functions
%   wpjoin          - Recompose wavelet packet
%   wprcoef         - Reconstruct wavelet packet coefficients
%   wprec           - Wavelet packet reconstruction 1-D 
%   wprec2          - Wavelet packet reconstruction 2-D
%   wpsplt          - Split (decompose) wavelet packet
%
% Multisignal Wavelet Analysis: One-Dimensional
%   chgwdeccfs  - Change Multisignal 1-D decomposition coefficients
%   mdwtdec     - Multisignal 1-D wavelet decomposition 
%   mdwtrec     - Multisignal 1-D wavelet reconstruction 
%   mswcmp      - Multisignal 1-D compression using wavelets 
%   mswcmpscr   - Multisignal 1-D wavelet compression scores
%   mswcmptp    - Multisignal 1-D compression thresholds and performances
%   mswden      - Multisignal 1-D denoising using wavelets 
%   mswthresh   - Perform multisignal 1-D thresholding 
%   wdecenergy  - Multisignal 1-D decomposition energy repartition 
%   wmspca      - Multiscale principal component analysis 
%   wmulden     - Wavelet multivariate 1-D denoising 
%
% Lifting Functions
%   addlift           - Adding primal or dual lifting steps
%   bswfun            - Biorthogonal scaling and wavelet functions
%   displs            - Display lifting scheme
%   filt2ls           - Filters to lifting scheme
%   laurentPolynomial - Laurent polynomial
%   laurentMatrix     - Laurent matrix
%   ilwt              - Inverse 1-D lifting wavelet transform
%   ilwt2             - Inverse 2-D lifting wavelet transform
%   liftfilt          - Apply elementary lifting steps on filters
%   liftingScheme     - Lifting Scheme
%   liftingStep       - Elementary lifting step
%   liftwave          - Lifting scheme for usual wavelets
%   lsinfo            - Information about lifting schemes
%   ls2filt           - Lifting scheme to filters
%   lwt               - Lifting wavelet decomposition 1-D
%   lwt2              - Lifting wavelet decomposition 2-D
%   lwtcoef           - Extract or reconstruct 1-D LWT wavelet coefficients
%   lwtcoef2          - Extract or reconstruct 2-D LWT wavelet coefficients
%   wave2lp           - Laurent polynomial associated to a wavelet
%   wavenames         - Wavelet names information
%
% Denoising and Compression for Signals and Images
%   cmddenoise              - Command line interval dependent denoising
%   ddencmp                 - Default values for denoising or compression
%   mlptdenoise             - Denoising using the multiscale local 1-D polynomial transform
%   thselect                - Threshold selection for denoising
%   waveletSignalDenoiser   - Wavelet signal denoiser app
%   wbmpen                  - Penalized threshold for wavelet 1-D or 2-D denoising
%   wdcbm                   - Thresholds for wavelet 1-D using Birge-Massart strategy
%   wdcbm2                  - Thresholds for wavelet 2-D using Birge-Massart strategy
%   wdenoise                - Wavelet signal denoising
%   wdenoise2               - Wavelet image denoising
%   wden                    - Automatic 1-D denoising using wavelets
%   wdencmp                 - Denoising or compression using wavelets
%   wnoise                  - Generate noisy wavelet test data
%   wnoisest                - Estimate noise of 1-D wavelet coefficients
%   wpbmpen                 - Penalized threshold for wavelet packet denoising
%   wpdencmp                - Denoising or compression using wavelet packets
%   wpthcoef                - Wavelet packet coefficients thresholding
%   wthcoef                 - Wavelet coefficient thresholding 1-D
%   wthcoef2                - Wavelet coefficient thresholding 2-D
%   wthresh                 - Perform soft or hard thresholding
%   wthrmngr                - Threshold settings manager
%
% Other Wavelet Applications
%   dwtleader         - Multifractal 1-D wavelet leader estimates
%   sensingDictionary - Dictionary for matching and basis pursuit 
%   wfbm              - Synthesize fractional Brownian motion
%   wfbmesti          - Estimate fractal index
%   wfusimg           - Fusion of two images
%   wfusmat           - Fusion of two matrices or arrays
%   wmpdictionary     - Dictionary for matching pursuit
%   wmpalg            - Matching pursuit
%
% Signal Labeling
%   labeledSignalSet        - Labeled signal set
%   signalLabelDefinition   - Create signal label definitions
%
% Tree Management Utilities
%   allnodes    - Tree nodes
%   cfs2wpt     - Wavelet packet tree construction from coefficients
%   depo2ind    - Node depth-position to node index
%   disp        - Display information of WPTREE object
%   drawtree    - Draw wavelet packet decomposition tree (GUI)
%   dtree       - Constructor for the class DTREE
%   get         - Get tree object field contents
%   ind2depo    - Node index to node depth-position
%   isnode      - True for existing node
%   istnode     - Determine indices of terminal nodes
%   leaves      - Determine terminal nodes
%   nodeasc     - Node ascendants
%   nodedesc    - Node descendants
%   nodejoin    - Recompose node
%   nodepar     - Node parent
%   nodesplt    - Split (decompose) node
%   noleaves    - Determine nonterminal nodes
%   ntnode      - Number of terminal nodes
%   ntree       - Constructor for the class NTREE
%   otnodes     - Ordered terminal nodes for a 1-D wavelet packet tree
%   plot        - Plot tree object
%   plotdt      - Plot dual-tree or double density dual-tree
%   read        - Read values in tree object fields
%   readtree    - Read wavelet packet decomposition tree from a figure
%   set         - Set tree object field contents
%   tnodes      - Determine terminal nodes (obsolete - use LEAVES)
%   treedpth    - Tree depth
%   treeord     - Tree order
%   wptree      - Constructor for the class WPTREE
%   wpviewcf    - Plot wavelet packets colored coefficients
%   write       - Write values in tree object fields
%   wtbo        - Constructor for the class WTBO
%   wtreemgr    - NTREE object manager
%
% General Utilities
%   localmax    - Compute local maxima positions   
%   wcodemat    - Extended pseudocolor matrix scaling
%   wextend     - Extend a Vector or a Matrix
%   wkeep       - Keep part of a vector or a matrix
%   wrev        - Flip vector
%   wtbxmngr    - Wavelet Toolbox manager
%   wvarchg     - Find variance change points
%
% Wavelet Information
%   waveinfo        - Information on wavelets
%   waveletfamilies - Wavelet families and family members 
%
%

% Copyright 1995-2021 The MathWorks, Inc.



