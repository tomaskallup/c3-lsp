package document

import (
	"github.com/pherrymason/c3-lsp/pkg/fs"
	"github.com/pherrymason/c3-lsp/pkg/utils"
	"github.com/pkg/errors"
	"github.com/tliron/glsp"
	protocol "github.com/tliron/glsp/protocol_3_16"
)

type DocumentStore struct {
	RootURI   string
	documents map[string]*Document
	fs        fs.FileStorage
}

func NewDocumentStore(fs fs.FileStorage) *DocumentStore {
	return &DocumentStore{
		documents: map[string]*Document{},
		fs:        fs,
	}
}

func (s *DocumentStore) normalizePath(pathOrUri string) (string, error) {
	path, err := fs.UriToPath(pathOrUri)
	if err != nil {
		return "", errors.Wrapf(err, "unable to parse URI: %s", pathOrUri)
	}
	return fs.GetCanonicalPath(path), nil
}

func (s *DocumentStore) Open(params protocol.DidOpenTextDocumentParams, notify glsp.NotifyFunc) (*Document, error) {
	langID := params.TextDocument.LanguageID
	if langID != "c3" {
		return nil, nil
	}

	uri := params.TextDocument.URI
	path, err := s.normalizePath(uri)
	//s.logger.Debug(fmt.Sprintf("Opening %s :: %s", uri, path))

	if err != nil {
		return nil, err
	}
	// TODO test that document is created with the normalized path and not params.TextDocument.URI
	doc := NewDocumentFromString(path, params.TextDocument.Text)

	s.documents[path] = &doc
	return &doc, nil
}

func (s *DocumentStore) Close(uri protocol.DocumentUri) {
	delete(s.documents, uri)
}

func (s *DocumentStore) Get(pathOrURI string) (*Document, bool) {
	path, err := s.normalizePath(pathOrURI)
	//s.logger.Debugf("normalized path:%s", path)

	if err != nil {
		//s.logger.Errorf("Could not normalize path: %s", err)
		return nil, false
	}

	d, ok := s.documents[path]
	return d, ok
}

func (s *DocumentStore) Delete(docId string) {
	delete(s.documents, docId)
}

func (s *DocumentStore) Rename(oldDocURI string, newDocURI string) {
	oldDocId := utils.NormalizePath(oldDocURI)
	newDocId := utils.NormalizePath(newDocURI)

	if val, ok := s.documents[oldDocId]; ok {
		val.URI = newDocURI
		s.documents[newDocId] = val
		// Eliminar la clave antigua
		delete(s.documents, oldDocId)
	}
}
