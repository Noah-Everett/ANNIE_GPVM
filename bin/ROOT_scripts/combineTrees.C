using std::vector;
using std::string;

void combineTrees( string nFile_out, vector< string > nFiles ) 
{
    vector< string > fileNames;
    for( int i = 0; i < nFiles.size(); i++ )
        fileNames.push_back( "gntp." + nFiles[ i ] + ".gst.root" );
    
    string fileName_out = "gntp." + nFile_out + ".gst.root";
    TFile* file = TFile::Open( fileName_out.c_str(), "RECREATE" );
    TChain* chain = new TChain( "gst;1" );
    
    for( string fileName : fileNames )
        chain->Add( fileName.c_str() );

    chain->CloneTree( -1, "fast" ); 
    file->Write();
}