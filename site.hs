--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import           Text.Pandoc
--------------------------------------------------------------------------------


mathjaxExtensions :: Extensions
mathjaxExtensions = extensionsFromList 
                    [Ext_tex_math_dollars --  $...$ or $$...$$
                    ,Ext_tex_math_double_backslash --  \(...\) or \[...\]
                    ,Ext_latex_macros
                    ,Ext_inline_code_attributes 
                    ]
readMathjaxOptions :: ReaderOptions 
readMathjaxOptions = defaultHakyllReaderOptions
                {
                    readerExtensions = (readerExtensions defaultHakyllReaderOptions) <> mathjaxExtensions
                }
writeMathjaxOptions :: WriterOptions
writeMathjaxOptions = defaultHakyllWriterOptions 
                {
                    writerHTMLMathMethod = MathJax ""
                }
mathJaxAddedCompiler :: Compiler (Item String)
mathJaxAddedCompiler = pandocCompilerWith readMathjaxOptions writeMathjaxOptions



main :: IO ()
main = hakyllWith config $ do
    match "assets/**" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "pages/*md" $ do
        route $ setExtension "html"
        compile $ mathJaxAddedCompiler
            >>= loadAndApplyTemplate "templates/page.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    tags <- buildTags "posts/*" (fromCapture "tags/*.html")

    tagsRules tags $ \tag pattern -> do
        let title = "Posts tagged “" ++ tag ++ "”"
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll pattern
            let ctx = constField "title" title
                      `mappend` listField "posts" (postCtxWithTags tags) (return posts)
                      `mappend` defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/tag.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls


    match "posts/*" $ do
        route $ setExtension "html"
        compile $ mathJaxAddedCompiler
            >>= loadAndApplyTemplate "templates/post.html"    (postCtxWithTags tags)
            >>= loadAndApplyTemplate "templates/default.html" (postCtxWithTags tags)
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" (postCtxWithTags tags) (return posts) `mappend`
                    constField "title" "Prof Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls



    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- fmap (take 10) $ recentFirst =<< loadAll "posts/*"

            
            let indexCtx =
                    listField "posts" (postCtxWithTags tags) (return posts) `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateBodyCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    -- dateField "date" "%B %e, %Y" `mappend`
    dateField "date" "%Y-%m-%d" `mappend`
    defaultContext


postCtxWithTags :: Tags -> Context String
postCtxWithTags tags = tagsField "tags" tags `mappend` postCtx


config :: Configuration
config = defaultConfiguration
  { destinationDirectory = "/home/george/Web-hakyll/prof/docs"
  , providerDirectory    = "/home/george/Web-hakyll/prof"
  , storeDirectory       = "/home/george/Web-hakyll/prof/_cache"
  , tmpDirectory         = "/home/george/Web-hakyll/prof/_cache/tmp"  
  , previewPort          = 9090
  , deployCommand        = "bash /home/george/Web-hakyll/prof/deploy-prof.sh"
  }
