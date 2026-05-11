package grpc

import (
	"context"

	contactuc "github.com/paxyside/nox-wallet/internal/usecase/contact"
	"github.com/paxyside/nox-wallet/pkg/ethkit"
	pb "github.com/paxyside/nox-wallet/proto/gen/go/wallet"
	pbcontact "github.com/paxyside/nox-wallet/proto/gen/go/wallet/contact"
)

func (h *Handler) CreateContact(ctx context.Context, req *pb.CreateContactRequest) (*pb.CreateContactResponse, error) {
	addr, err := ethkit.NewAddress(req.GetAddress())
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	c, err := h.contact.Create(ctx, contactuc.CreateParams{
		Address: addr,
		Name:    req.GetName(),
		Notes:   req.GetNote(),
	})
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	return &pb.CreateContactResponse{Contact: contactToProto(c)}, nil
}

func (h *Handler) GetContact(ctx context.Context, req *pb.GetContactRequest) (*pb.GetContactResponse, error) {
	c, err := h.contact.GetByID(ctx, req.GetId())
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	return &pb.GetContactResponse{Contact: contactToProto(c)}, nil
}

func (h *Handler) UpdateContact(ctx context.Context, req *pb.UpdateContactRequest) (*pb.UpdateContactResponse, error) {
	c, err := h.contact.Update(ctx, contactuc.UpdateParams{
		ID:    req.GetId(),
		Name:  req.GetName(),
		Notes: req.GetNote(),
	})
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	return &pb.UpdateContactResponse{Contact: contactToProto(c)}, nil
}

func (h *Handler) DeleteContact(ctx context.Context, req *pb.DeleteContactRequest) (*pb.DeleteContactResponse, error) {
	if err := h.contact.Delete(ctx, req.GetId()); err != nil {
		return nil, h.HandleError(ctx, err)
	}

	return &pb.DeleteContactResponse{}, nil
}

func (h *Handler) FavoriteContact(
	ctx context.Context,
	req *pb.FavoriteContactRequest,
) (*pb.FavoriteContactResponse, error) {
	if err := h.contact.SetFavorite(ctx, req.GetId(), req.GetFavorite()); err != nil {
		return nil, h.HandleError(ctx, err)
	}

	return &pb.FavoriteContactResponse{}, nil
}

func (h *Handler) ListContacts(ctx context.Context, _ *pb.ListContactsRequest) (*pb.ListContactsResponse, error) {
	list, err := h.contact.List(ctx)
	if err != nil {
		return nil, h.HandleError(ctx, err)
	}

	contacts := make([]*pbcontact.Contact, 0, len(list))
	for _, c := range list {
		contacts = append(contacts, contactToProto(c))
	}

	return &pb.ListContactsResponse{Contacts: contacts}, nil
}
