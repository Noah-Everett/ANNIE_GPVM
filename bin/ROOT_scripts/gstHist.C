// Just going to preface this script by saying that it is not efficient at all.
// There are several postions in here that could be made O(x) but are O(x^2) or O(x^3).
// Dont use an absorbent amount of files and you wont notice.

using std::string;
using std::vector;
using std::map;

const vector< Color_t >     kColors         = { kRed, kBlue, kGreen, kYellow, kPink+10, kViolet, kMagenta+4 };
const map< string, string > kTitles         = { { "nfn", "Final-State Neutrons" }, { "Q2", "Momentum Transfer" } };
const map< string, string > kXaxisTitles    = { { "nfn", "Neutron Multiplicity" }, { "Q2", "Momentum Transfer [GeV^2]" } };
const map< string, string > kYaxisTitles    = { { "nfn", "Events" }, { "Q2", "Counts/GeV^2" } };
const map< string, string > kBranchVarTypes = { { "nfn", "int" }, { "Q2", "double" } };
const map< string, int    > kPdgCodes       = { { "H1"  , 1000010010 }, { "C12" , 1000060120 },
                                                { "N14" , 1000070140 }, { "O16" , 1000080160 },
                                                { "Na23", 1000110230 }, { "Mg24", 1000120240 },
                                                { "Al27", 1000130270 }, { "Si28", 1000140280 },
                                                { "Ar40", 1000180400 }, { "K39" , 1000190390 },
                                                { "Ca40", 1000200400 }, { "Fe56", 1000260560 } };

int makeHist( const vector< string >& t_files, const string& t_branch, const string& t_target, const string& t_options );
int getDigits( const int& t_int );

void gstHist( vector< string > t_files, string t_branch, string t_target, string t_options ) 
{
    for( char option : t_options )
        if( option == 'H' | option == 'h' ) {
            cout << "Usage Statement:" << endl;
            cout << endl;
            cout << "Command line usage:" << endl;
            cout << "$ root -l /path/to/gstHist.C\\(\\{"
                 << "\\\"/path/to/gntp.<file number>.gst.root\\\",...,"
                 << "\\\"/path/to/gntp.<file number>.gst.root\\\"\\},"
                 << "\\\"<branch name>\\\",\\\"<options>\\\"\\)" << endl;
            cout << endl;
            cout << "ROOT usage:" << endl;
            cout << "root [#] .x /path/to/gstHist.C({"
                 << "\"/path/to/gntp.<file number>.gst.root\",...,"
                 << "\"/path/to/gntp.<file number>.gst.root\"},"
                 << "\"<branch name>\",\"<options>\")" << endl;
            cout << endl;

            return 1;
        }

    if( !kPdgCodes.count( t_target ) ) cerr << "Invalid t_target. Ex Ar40 | O16" << endl;

    if( makeHist( t_files, t_branch, t_target, t_options ) != 0 ) return 1;

    return 0;
    
}

int makeHist( const vector< string >& t_files, const string& t_branch, const string& t_target, const string& t_options )
{
    bool oPercent = false;
    bool oFill    = false;
    for( char option : t_options ) {
             if( option == 'P' | option == 'p' ) oPercent = true;
        else if( option == 'F' | option == 'f' ) oFill    = true;
        else {
            cerr << "Invalid char in `t_options`: \"option\". For usage statement include 'H' in `t_options`";
            return 1;
        }
    }

    TFile* file;
    TTree* tree;
    TH1F * hists[ t_files.size() ];

    string type = kBranchVarTypes.at( t_branch );
    string opt = "HIST";

    int    size;
    double cur_double;
    int    cur_int;
    int    cur_tgt;
    double maxes[ t_files.size() ];
    double max;
    vector< double > branches[ t_files.size() ];
    bool error = false;

    for( int i = 0; i < t_files.size(); i++ ) {
        cout << "Retrieving information from file: `" << t_files[ i ] << "`, branch: `" << t_branch << "`." << endl;
        file = TFile::Open( t_files[ i ].c_str() );
        tree = ( TTree* )file->Get( "gst;1" );

        size = tree->GetEntries();
        max = 0;
             if( type == "int"    ) tree->SetBranchAddress( t_branch.c_str(), &cur_int    );
        else if( type == "double" ) tree->SetBranchAddress( t_branch.c_str(), &cur_double );
        else                        tree->SetBranchAddress( t_branch.c_str(), &cur_double );
        tree->SetBranchAddress( "tgt", &cur_tgt );

        for( Int_t j = 0; j < size; j++ ) {
            tree->GetEntry( j );
            if( t_target != 0 && cur_tgt == kPdgCodes.at( t_target ) ) {
                     if( type == "int" )    branches[ i ].push_back( cur_int    );
                else if( type == "double" ) branches[ i ].push_back( cur_double );
                else                        branches[ i ].push_back( cur_double );

                     if( type == "int" )    { if( cur_int    > maxes[ i ] ) maxes[ i ] = cur_int   ; }
                else if( type == "double" ) { if( cur_double > maxes[ i ] ) maxes[ i ] = cur_double; }
                else                        { if( cur_double > maxes[ i ] ) maxes[ i ] = cur_double; }
            }
        }
    }
    
    for( int i = 0; i < t_files.size(); i++ ) 
        if( branches[ i ].size() == 0 ) {
            cerr << "branches[ " << i << " ] has size = 0. Change target or input files." << endl;
            error = true;
        }
    if( error ) return 1;

    cout << "Finding maximum value from all files." << endl;
    for( int i = 0; i < t_files.size(); i++ )
        if( maxes[ i ] > max ) max = maxes[ i ];

    for( int i = 0; i < t_files.size(); i++ ) {
        cout << "Making histogram for file: `" << t_files[ i ] << "`, branch: `" << t_branch << "`." << endl;

        string title = kTitles.at( t_branch );
        if( t_target != 0 ) title += " (Events in " + t_target + ")";
    
        if( type == "int" )
            hists[ i ] = new TH1F( t_files[ i ].c_str(), title.c_str(), max, 0, max );
        else if( type == "double" )
            hists[ i ] = new TH1F( t_files[ i ].c_str(), title.c_str(), max * 20, 0, max );
        else
            hists[ i ] = new TH1F( t_files[ i ].c_str(), title.c_str(), max * 20, 0, max );

        for( int j = 0; j < branches[ i ].size(); j++ )
            hists[ i ]->Fill( branches[ i ][ j ] );

        if( oFill ) { 
            hists[ i ]->SetFillColorAlpha( kColors[ i ], 0.2 );
            hists[ i ]->SetLineColorAlpha( kColors[ i ], 0.8 );
            hists[ i ]->SetLineWidth     ( 3 );
        } else {
            hists[ i ]->SetLineColorAlpha( kColors[ i ], 0.95 );
            hists[ i ]->SetLineWidth     ( 4 );
        }
        if( oPercent ) {
            hists[ i ]->Scale( 1 / double( branches[ i ].size() ) * 100, "nosw2" );
            hists[ i ]->GetYaxis()->SetTitle( ( kYaxisTitles.at( t_branch ) + " [%]" ).c_str() );
        } else {
            hists[ i ]->GetYaxis()->SetTitle( kYaxisTitles.at( t_branch ).c_str() );
        }
        hists[ i ]->GetXaxis()->SetTitle( kXaxisTitles.at( t_branch ).c_str() );
        hists[ i ]->GetXaxis()->SetTitleOffset( 1.15 );
    }

    cout << "Making and filling legend." << endl;
    TLegend* legend = new TLegend();
    for( int i = 0; i < t_files.size(); i++ )
        legend->AddEntry( hists[ i ], t_files[ i ].c_str(), "l" );

    // Literally insertion sorting histograms. lol
    cout << "Sorting histograms." << endl;
    for( int i = 1; t_files.size() > 1 && i < t_files.size(); i++ ) {
        for( int j = 0 ; i - j - 1 >= 0 && hists[ i - j - 1 ]->GetBinContent( hists[ i - j - 1 ]->GetMaximumBin() ) < 
                                           hists[ i - j ]->GetBinContent( hists[ i - j ]->GetMaximumBin() ); j++ ) {
            cout << "    Swapping `hists[ " << i - j - 1 << " ]` and `hists[ " << i - j << " ]`." << endl;
            TH1F* temp = hists[ i - j - 1 ];
            hists[ i - j - 1 ] = hists[ i - j ];
            hists[ i - j ] = temp;
        }
    }
    cout << "Sorted histograms:" << endl;
    for( int i = 0; i < t_files.size(); i++ )
        cout << "    `hists[ " << i << " ]` --> Max bin size = " << hists[ i ]->GetBinContent( hists[ i ]->GetMaximumBin() ) << "." << endl;

        for( int i = 0; i < t_files.size(); i++ )
            hists[ i ]->GetYaxis()->SetTitleOffset( 0.7 + 
            0.1 * ( getDigits( hists[ 0 ]->GetBinContent( hists[ 0 ]->GetMaximumBin() ) ) - 1 ) );

    TCanvas* canvas = new TCanvas( t_branch.c_str(), kTitles.at( t_branch ).c_str() );
    for( int i = 0; i < t_files.size(); i++ ) {
        cout << "Drawing histogram for file: `" << t_files[ i ] << "`, branch: `" << t_branch << "`." << endl;
        hists[ i ]->Draw( opt.c_str() );
        opt = "Sames";
    }
    cout << "Drawing legend." << endl;
    legend->Draw( "Same" );

    return 0;
}

int getDigits( const int& t_int ) {
    int integer = t_int;

    if( t_int == 0 )
        return 1;

    int digits = 1;
    for( ; integer / 10 > 0; integer /= 10, ++digits ) {}

    return digits;
}