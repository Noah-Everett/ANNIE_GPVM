using std::string;
using std::vector;

void make_hist_nfn_Q2( string t_fileName, string t_target )
{   
    TCanvas* canvas = new TCanvas( "canvas", "Final-State Neutrons vs Momentum Transfer" );
    TFile  * file   = TFile::Open( t_fileName.c_str() );
    TTree  * tree   = ( TTree* )file->Get( "gst;1" );
    
    int      tgt;
         if( t_target == "H1"   ) tgt = 1000010010;
    else if( t_target == "C12"  ) tgt = 1000060120;
    else if( t_target == "N14"  ) tgt = 1000070140;
    else if( t_target == "O16"  ) tgt = 1000080160;
    else if( t_target == "Na23" ) tgt = 1000110230;
    else if( t_target == "Mg24" ) tgt = 1000120240;
    else if( t_target == "Al27" ) tgt = 1000130270;
    else if( t_target == "Si28" ) tgt = 1000140280;
    else if( t_target == "Ar40" ) tgt = 1000180400;
    else if( t_target == "K39"  ) tgt = 1000190390;
    else if( t_target == "Ca40" ) tgt = 1000200400;
    else if( t_target == "Fe56" ) tgt = 1000260560;
    else cerr << "Invalid t_target. Ex Ar40 | O16" << endl;

    vector< double > nfn;
    vector< double > Q2;
    int    cur_nfn;
    double cur_Q2;
    int    cur_tgt;
    int    max_nfn = 0;
    double max_Q2  = 0;

    tree->SetBranchAddress( "nfn", &cur_nfn );
    tree->SetBranchAddress( "Q2",  &cur_Q2  );
    tree->SetBranchAddress( "tgt", &cur_tgt );

    for( Int_t i = 0; i < tree->GetEntries(); i++ ) {
        tree->GetEntry( i );
        if( cur_tgt == tgt ) {
            nfn.push_back( cur_nfn );
            Q2.push_back( cur_Q2 );
            if( cur_nfn > max_nfn ) max_nfn = cur_nfn;
            if( cur_Q2  > max_Q2  ) max_Q2  = cur_Q2 ;
        }
    } 

    TH2F* hist = new TH2F( "Events in Argon", 
                           "Final-State Neutrons vs Momentum Transfer;Momentum Transfer [GeV^2];Neutron Multiplicity",
                           ( ceil( max_Q2 ) ) * 7, 0, ceil( max_Q2 ),
                           max_nfn, 0, max_nfn );
    for( int i = 0; i < nfn.size(); i++ )
        hist->Fill( Q2[ i ], nfn[ i ] );

    hist->GetXaxis()->SetTitleOffset( 1.15 );
    hist->GetYaxis()->SetTitleOffset( 0.7 );

    TProfile* profile = hist->ProfileX();
    profile->SetLineColor( kRed );
    profile->SetLineWidth( 3 );

    TLegend* legend = new TLegend();
    legend->AddEntry( profile, "Average curve", "l" );
    legend->SetBorderSize( 0 );

    // gPad->SetFrameFillColor( kBlue-2 );

    hist->Draw( "COLZ" );
    profile->Draw( "Same" );
    legend->Draw( "Same" );
}