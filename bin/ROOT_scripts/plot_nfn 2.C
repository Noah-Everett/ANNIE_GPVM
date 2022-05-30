using std::string;
using std::vector;

void plot_nfn( string nFile ) 
{
    TCanvas* canvas = new TCanvas( "nfn", "Final-State Neutrons" );

    string fileName = "gntp." + nFile + ".gst.root";
    TFile* file = TFile::Open( fileName.c_str() );
    TTree* tree = ( TTree* )file->Get( "gst;1" );
    
    const unsigned int size = tree->GetEntries();
    int nfn_cur;
    int nfn_max;
    vector< int > nfn;
    tree->SetBranchAddress( "nfn", &nfn_cur );

    for( Int_t i = 0; i < size; i++ ) {
        tree->GetEntry( i );
        nfn.push_back( nfn_cur );

        if( nfn_cur > nfn_max ) nfn_max = nfn_cur;
    }
    
    TH1F* hist = new TH1F( "", "Final-State Neutrons", nfn_max + 1, 0, nfn_max );
    for( int i = 0; i < size; i++ ) {
        hist->Fill( nfn[ i ] );
    }
    hist->SetFillColorAlpha( kRed, 0.2 );
    hist->Draw();
}